// @license@ 
package nanosome.notify.field.bool {
	
	import nanosome.notify.field.Field;
	import nanosome.notify.field.IBoolField;
	
	/**
	 * Default implementation of <code>IBoolField</code>
	 * 
	 * @author Martin Heidegger
	 * @version 1.0
	 */
	public class BoolField extends Field implements IBoolField {
		
		private var _bool: Boolean;
		private var _changeable: Boolean;
		
		/**
		 * Constructs a new <code>BoolField</code> instance 
		 */
		public function BoolField( value: Boolean = false, changeable: Boolean = false ) {
			super( value );
			_changeable = changeable;
		}
		
		override protected function notifyValueChange(oldValue : *, newValue : *) : void {
			_bool = ( value == true );
			super.notifyValueChange(oldValue, newValue);
		}
		
		override public function setValue( value: * ): Boolean {
			if( !_changeable ) {
				super.setValue( value );
				return true;
			} else {
				return false;
			}
		}
		
		override public function get isChangeable(): Boolean {
			return !_changeable;
		}

		public function flip(): Boolean {
			value = !_bool;
			return _bool;
		}
		
		public function yes(): Boolean {
			if( !_bool ) {
				value = true;
				return true;
			} else {
				return false;
			}
		}
		
		public function no(): Boolean {
			if( !_bool ) {
				value = false;
				return true;
			} else {
				return false;
			}
		}
		
		public function get isTrue() : Boolean {
			return _bool;
		}
		
		public function get isFalse() : Boolean {
			return !_bool;
		}
	}
}
