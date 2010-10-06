// @license@

package nanosome.notify.field.bool {
	import nanosome.notify.field.Field;
	import nanosome.notify.field.IBoolField;
	import nanosome.notify.field.IField;
	import nanosome.notify.field.IFieldObserver;
	
	
	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public final class NotWrapper extends Field implements IBoolField, IFieldObserver {
		
		private var _target: IBoolField;
		
		public function NotWrapper( target: IBoolField ) {
			super( null );
			if( !target ) {
				throw new Error( "Target Field is required." );
			}
			_target = target;
		}
		
		override public function dispose(): void {
			super.dispose();
			_target.removeObserver( this );
			_target = null;
		}
		
		override public function addObserver( observer: IFieldObserver,
						executeImmediatly: Boolean = false, weakReference: Boolean = false): Boolean {
			if( super.addObserver(observer, executeImmediatly, weakReference) ) {
				// Only add as observer if there is a observer on this one
				_target.addObserver( this );
				return true;
			} else {
				return false;
			}
		}
		
		override public function removeObserver( observer: IFieldObserver ): Boolean {
			if( super.removeObserver(observer) ) {
				if( !hasObservers ) {
					_target.removeObserver( this );
				}
				return true;
			} else {
				return false;
			}
		}
		
		override public function setValue( value: * ): Boolean {
			return _target.setValue( value );
		}
		
		override public function get value(): * {
			return _target.value;
		}
		
		override public function get isChangeable() : Boolean {
			return _target.isChangeable;
		}
		
		public function flip() : Boolean {
			return _target.flip();
		}
		
		public function yes() : Boolean {
			return _target.no();
		}
		
		public function no() : Boolean {
			return _target.yes();
		}
		
		public function get isTrue() : Boolean {
			return _target.isFalse;
		}
		
		public function get isFalse() : Boolean {
			return _target.isTrue;
		}
		
		public function onFieldChange( mo: IField, oldValue: * = null, newValue: * = null ): void {
			notifyValueChange( oldValue, newValue );
		}
	}
}
