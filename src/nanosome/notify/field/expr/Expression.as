// @license@ 
package nanosome.notify.field.expr {
	
	import org.mockito.integrations.inOrder;
	import nanosome.notify.field.system.DPI;
	import nanosome.notify.field.IBoolField;
	import nanosome.notify.field.system.X_SIZE;
	import nanosome.notify.field.system.FONT_SIZE;
	import nanosome.notify.field.NumberField;
	import nanosome.notify.field.Field;
	import nanosome.notify.field.IField;
	import nanosome.notify.field.IFieldObserver;
	import nanosome.notify.field.INumberField;
	import nanosome.notify.field.expr.value.IValue;
	
	import flash.utils.Dictionary;
	
	/**
	 * <code>Expression</code> is a powerful system to evaluate algebraic expressions.
	 * 
	 * <p>Expression takes on a input as string (and parses it) or a number. It allows
	 * place holders that refer to static and to dynamic values. It also supports
	 * visual units like "em" or "cm" that allow straight statements.</p>
	 * 
	 * <p>The expression syntax has a short hand constructor called <code>expr</code>.
	 * Its recommended to use this.</p>
	 * 
	 * <p>Possible inputs to be parsed might be:</p>
	 * <listening>
	 *    expr(1); //　1
	 *    expr("1"); // 1
	 *    expr(null); // NaN
	 *    expr("1+1"); // 2
	 *    expr("1+{a}/100").field("a",200); // 3
	 *    expr("1%").base(400); // 4
	 *    expr("1cm"); // renders the current value in dpi
	 * </listening>
	 * 
	 * <p>Expressions also allow stacked definitions.</p>
	 * <listening>
	 *    var e: Expression =
	 *               expr("{a}*10+2%-{b}+{c}")
	 *                  .field(a, 90)
	 *                  .base(200)
	 *                  .fields({
	 *                    b: 200,
	 *                    c: 300
	 *                  });
	 *     e.asNumber; // contains 1004
	 * </listening>
	 * 
	 * <p>As soon as you start observe this field it will add itself as observer
	 * to all the reference fields. Make sure that you unlink from a expression
	 * properly.</p>
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @version 1.0
	 * 
	 * @TODO Expressions still might persist in memory if only weak reference are added implement
	 *       a clean up mechanism for that case.
	 */
	public class Expression extends Field implements IFieldObserver, INumberField, IBoolField {
		
		// Empty object to be used to 
		private static const EMPTY: Object = {};
		
		// Actual dynamic value
		private var _result: IValue;
		
		// Base value to calculate the % values from
		private var _base: INumberField;
		
		// Set of the field names and their number values (used for processing expressions)
		private var _fields: Object /* String -> Number */;
		
		// Contains a list of names under which the the fields are required
		private var _fieldRegistry: Dictionary /* INumberField -> Array[ String ] */;
		
		// Mapping of targets to their names
		private var _fieldTargets: Object /* String -> INumberField */;
		
		// Stores the current value as number
		private var _number: Number;
		
		// Stores the current value as integer
		private var _int: int;
		
		/**
		 * Constructs a new <code>Expression</code>.
		 * 
		 * @param expression Expression will be parsed.
		 * @throws ExpressionParseError if a expression can not be parsed.
		 */
		public function Expression( expression: * ) {
			super();
			
			_result = PARSER.parse( expression );
			if( _result ) {
				if( _result.isStatic ) {
					_number = _result.getValue();
					if( _number == Infinity ) {
						_int = int.MAX_VALUE;
					} else if( _number == -Infinity ) {
						_int = int.MIN_VALUE;
					} else {
						_int = _number;
					}
					_result = null;
				} else {
					if( _result.requiresFontSize ) {
						FONT_SIZE.addObserver( this );
						X_SIZE.addObserver( this );
					}
					if( _result.requiresDPI ) {
						DPI.addObserver( this );
					}
					updateValue();
					checkAllFields();
				}
			} else {
				_number = NaN;
				_int = NaN;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function setValue( value: * ): Boolean {
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get value(): * {
			return _number;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function addObserver( observer: IFieldObserver, executeImmediately: Boolean = false,
													weakReference: Boolean = false  ): Boolean {
			var result: Boolean = super.addObserver(observer);
			if( executeImmediately ) {
				observer.onFieldChange( this, null, _number );
			}
			if( result ) {
				checkAllFields();
			}
			return result;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function removeObserver( observer: IFieldObserver ): Boolean {
			var result: Boolean = super.removeObserver(observer);
			if( result ) {
				checkAllFields();
			}
			return result;
		}
		
		/**
		 * List of the fields that are required to properly calculate the value of
		 * the expression.
		 */
		public function get requiredFields(): Array /* String */ {
			return _result.requiredFields;
		}
		
		/**
		 * Defines the base to be used when stating "%" values.
		 * 
		 * @param value Number to calculate the percentage from.
		 * @return this expression
		 */
		public function base( value: * ): Expression {
			var base: INumberField = getNumberField( value );
			if( _result.requiresBase )
			{
				var old: INumberField = _base;
				_base = base;
				checkObserving( old );
				checkObserving( base );
				updateValue();
			}
			return this;
		}
		
		/**
		 * Useful shorthand method to <code>addObserver</code>.
		 * 
		 * @param observer observer to be added
		 * @return this expression
		 */
		public function notify( observer: IFieldObserver ): Expression {
			addObserver( observer );
			return this;
		}
		
		/**
		 * Defines the value for one <code>field</code> by its <code>fieldName</code>
		 * 
		 * @param fieldName Name of the field.
		 * @param value value for the field
		 * @return this expression
		 */
		public function field( fieldName: String, value: * ): Expression {
			removeField( fieldName );
			// Only add the field as important if the expression makes use of it.
			if( _result.requiredFields && _result.requiredFields.indexOf( fieldName ) != -1 )
			{
				var target: INumberField = getNumberField( value );
				if( !_fieldTargets ) {
					_fieldRegistry = new Dictionary();
					_fieldTargets = {};
				}
				_fieldTargets[ fieldName ] = target;
				var namesForValue: Array = _fieldRegistry[ target ] || ( _fieldRegistry[ target ] = [] );
				if( namesForValue.indexOf( fieldName ) == -1 ) {
					namesForValue.push( fieldName );
				}
				if( checkObserving( target ) ) {
					( _fields || ( _fields = {} ) )[ fieldName ] = target.asNumber;
				}
				updateValue();
			}
			return this;
		}
		
		/**
		 * Defines a set of field 
		 * 
		 * @param fields New fields to be defined
		 * @param clearAll Clears all former defined fields.
		 * @return this expression
		 */
		public function fields( fields: Object, clearAll: Boolean = false ): Expression {
			if( clearAll ) {
				clearFields();
			}
			for( var fieldName: String in fields ) {
				field( fieldName, fields[ fieldName ] );
			}
			return this;
		}
		
		public function clearFields(): Expression {
			for( var target: * in _fieldRegistry ) {
				removeTarget( target );
			}
			return this;
		}
		
		public function removeField( fieldName: String ): Expression {
			if( _fieldTargets ) {
				var target: Expression = _fieldTargets[ fieldName ];
				var list: Array = _fieldRegistry[ target ];
				if( list ) {
					var index: int = list.indexOf( fieldName );
					delete _fields[ fieldName ];
					if( index != -1 ) {
						if( list.length == 0 ) {
							delete _fieldRegistry[ target ];
						} else {
							list.splice( index, 1 );
						}
					}
					checkAllFields();
					updateValue();
				}
			}
			return this;
		}
		
		public function removeTarget( target: INumberField ): Expression {
			var list: Array = _fieldRegistry[ target ];
			if( list ) {
				while( list.length > 0 ) {
					var fieldName: String = list.pop();
					delete _fields[ fieldName ];
					delete _fieldTargets[ fieldName ];
				}
				delete _fieldRegistry[ target ];
				updateValue();
			}
			return this;
		}
		
		private function getNumberField( value: * ): INumberField {
			if( value is INumberField ) {
				return value;
			} else if( value is IField ) {
				return new NumberFieldWrapper( value );
			} else {
				return new NumberField( value );
			}
		}
		
		private function checkObserving( value: INumberField ): Boolean {
			if( _result && value ) {
				if( ( value == _base || _fieldRegistry[ value ] ) ) {
					value.addObserver( this );
					return true;
				} else {
					value.removeObserver( this );
				}
			}
			return false;
		}
		
		private function updateValue(): void {
			if( _result ) {
				var base: Number = NaN;
				if( _base ) {
					base = _base.asNumber;
				}
				var newValue: Number = _result.getValue( base, DPI.asNumber, FONT_SIZE.asNumber,
					X_SIZE.asNumber, _fields || EMPTY );
				if( newValue != _number ) {
					if( newValue == Infinity ) {
						_int = int.MAX_VALUE;
					} else if( _number == -Infinity ) {
						_int = int.MIN_VALUE;
					} else {
						_int = newValue;
					}
					notifyValueChange( _number, _number = newValue );
				}
			}
		}
		
		private function checkAllFields(): void {
			var oneFound: Boolean = false;
			for( var fieldName: String in _fieldTargets ) {
				oneFound = checkObserving( _fieldTargets[ fieldName ] ) || oneFound;
			}
			if( oneFound ) {
				_fields = {};
			} else {
				_fields = null;
			}
		}
		
		override public function dispose(): void {
			super.dispose();
			clearFields();
			base( null );
		}
		
		public function onFieldChange( field: IField, oldValue: * = null, newValue: * = null ) : void {
			if( _fieldRegistry ) {
				// base might leave a empty registry
				var fields: Array = _fieldRegistry[ field ];
				if( fields ) {
					// base might have no fields!
					var i: int = fields.length;
					while( --i -(-1) ) {
						_fields[ fields[i] ] = isNaN( newValue ) ? 0 : newValue;
					}
				}
			}
			updateValue();
		}
		
		public function get asNumber(): Number {
			return _number;
		}
		
		public function get asInt(): int {
			return _int;
		}
		
		override public function get isChangeable(): Boolean {
			return false;
		}
		
		public function yes(): Boolean {
			return false;
		}
		
		public function no(): Boolean {
			return false;
		}
		
		public function flip(): Boolean {
			return false;
		}
		
		public function get isTrue(): Boolean {
			return _int !== 0;
		}
		
		public function get isFalse(): Boolean {
			return _int === 0;
		}
	}
}
