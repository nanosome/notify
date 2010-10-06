// @license@

package nanosome.notify.field.bool {
	import nanosome.notify.field.Field;
	import nanosome.notify.field.IBoolField;
	import nanosome.notify.field.IField;
	import nanosome.notify.field.IFieldObserver;
	
	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	internal class AndField extends Field implements IBoolField, IFieldObserver {
		
		protected var _fields: Array;
		protected var _l: int;
		
		private var _isTrue: Boolean;
		private var _isFalse: Boolean;
		
		public function AndField( mos: Array ) {
			super( mos );
		}
		
		override protected function notifyValueChange( oldValue: *, newValue: * ): void {
			
			var i: int;
			var l: int;
			var any: *;
			
			// Clear off the old fields
			if( _fields ) {
				l = _fields.length;
				for( i=0; i<l; ++i ) {
					any = _fields[i];
					if( any is IField ) {
						IField( any ).removeObserver( this );
					}
				}
			}
			
			var fields: Array = newValue as Array;
			if( !fields ) {
				any = createBoolMo( value );
				_fields = [ any ];
				_l = 1;
			} else {
				_fields = [];
				l = fields.length;
				for( i=0; i<l; ++i ) {
					any = createBoolMo( fields[i] );
					if( any ) {
						_fields[ _fields.length ] = any;
					}
				}
				_l = _fields.length;
			}
			
			super.notifyValueChange( oldValue, newValue );
		}
		
		private function createBoolMo( value: * ): IBoolField {
			if( value == null ) {
				return null;
			} else {
				if( value is IField ) {
					value = new BoolFieldWrapper( value );
				}
				if( value is IBoolField ) {
					IBoolField( value ).addObserver( this, true );
				} else {
					value = value ? TRUE : FALSE;
				}
				return value;
			}
		}
		
		public function flip() : Boolean {
			return setValue( !isTrue );
		}
		
		public function yes(): Boolean {
			return setValue( true );
		}
		
		public function no() : Boolean {
			return setValue( false );
		}
		
		public function get isTrue(): Boolean {
			return _isTrue;
		}
		
		public function get isFalse(): Boolean {
			return _isFalse;
		}
		
		override public function dispose() : void {
			super.dispose();
			value = null;
		}
		
		private function update() : void {
			var isTrue: Boolean = getValue();
			if( isTrue != _isTrue ) {
				_isFalse = !_isTrue;
				notifyStateChange();
			}
		}
		
		protected function getValue(): Boolean {
			for( var i:int=0; i<_l; ++i ) {
				if( IBoolField( _fields[i] ).isFalse ) {
					return false;
				}
			}
			return true;
		}
		
		public function onFieldChange( field: IField, oldValue : * = null, newValue : * = null) : void {
			update();
		}
	}
}
