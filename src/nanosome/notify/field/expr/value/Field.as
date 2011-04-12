// @license@ 
package nanosome.notify.field.expr.value {
	
	/**
	 * <code>Field</code> uses the value of a passed-in field.
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @version 1.0
	 */
	public final class Field implements IValue {
		
		// Name of the field to be read
		private var _fieldName: String;
		
		// Storage for the required fields
		private var _requiredFields: Array;
		
		/**
		 * Creates a new Field instance.
		 * 
		 * @param field name of the field to be taken
		 */
		public function Field( field: String ) {
			_fieldName = field;
			_requiredFields = [ field ];
		}
		
		/**
		 * @inheritDoc
		 */
		public function getValue( base: Number = 0.0, dpi: Number = 0.0,
									fontBase: Number = 0.0, xSize: Number = 0.0,
									fields: Object = null  ): Number {
			return fields[ _fieldName ] || NaN;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get requiredFields(): Array {
			return _requiredFields;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get requiresBase(): Boolean {
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get requiresFontSize(): Boolean {
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get requiresDPI(): Boolean {
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get isStatic(): Boolean {
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function equals( value: IValue ): Boolean {
			if( value == this ) {
				return true;
			}
			if( value is Field ) {
				return Field( value )._fieldName == _fieldName;
			}
			return false;
		}
	}
}
