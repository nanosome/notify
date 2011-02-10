// @license@ 
package nanosome.notify.field {

	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public class NumberField extends Field implements INumberField {
		
		private var _number: Number;
		private var _int: int;
		
		public function NumberField( value: * = null ) {
			super( value );
		}
		
		override protected function notifyValueChange( oldValue: *, newValue: * ): void {
			_number = newValue as Number;
			_int = newValue as int;
			super.notifyValueChange( oldValue, newValue );
		}
		
		public function get asNumber(): Number {
			return _number;
		}
		
		public function get asInt(): int {
			return _int;
		}
	}
}
