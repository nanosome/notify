// @license@ 
package nanosome.notify.field.expr {
	
	import nanosome.notify.field.IFieldObserver;
	import nanosome.notify.field.Field;
	import nanosome.notify.field.IField;
	import nanosome.notify.field.INumberField;
	
	/**
	 * Wraps a common <code>IField</code> to be used as <code>INumberField</code>
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @version 1.0
	 */
	public class NumberFieldWrapper extends Field implements IFieldObserver, INumberField {
		
		// The wrapped field
		private var _field: IField;
		
		// The 
		private var _number: Number;
		private var _int: int;
		
		public function NumberFieldWrapper( field: IField ) {
			_field = field;
			_field.addObserver( this, true, true );
		}
		
		protected function update( oldValue: *, newValue: * ): void {
			_number = newValue as Number;
			_int = _number as int;
			notifyValueChange( oldValue, newValue );
		}
		
		public function get asNumber(): Number {
			if( hasObservers ) {
				return _number;
			} else {
				return _field.value as Number;
			}
		}
		
		public function get asInt(): int {
			if( hasObservers ) {
				return _int;
			} else {
				return _field.value as int;
			}
		}
		
		public function onFieldChange( field: IField, oldValue: * = null, newValue: * = null ): void {
			update( oldValue, newValue );
		}
	}
}
