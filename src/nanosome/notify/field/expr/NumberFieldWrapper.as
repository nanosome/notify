package nanosome.notify.field.expr {
	import nanosome.notify.field.IFieldObserver;
	import nanosome.notify.field.Field;
	import nanosome.notify.field.IField;
	import nanosome.notify.field.INumberField;
	
	
	/**
 * @author mh
 */
	public class NumberFieldWrapper extends Field implements IFieldObserver, INumberField {
		
		private var _field: IField;
		private var _number: Number;
		private var _int: int;
		
		public function NumberFieldWrapper( field: IField ) {
			_field = field;
			_field.addObserver( this, true, true );
		}
		
		protected function update(): void {
			_number = _field.value as Number;
			_int = _number as int;
			notifyValueChange( null, null );
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
			update();
		}
	}
}
