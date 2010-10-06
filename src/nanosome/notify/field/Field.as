// @license@
package nanosome.notify.field {
	
	
	import flash.utils.getQualifiedClassName;
	import nanosome.util.IDisposable;
	import nanosome.util.UID;
	import nanosome.notify.field.impl.ObserverList;
	import nanosome.notify.field.impl.OBSERVER_LIST_POOL;

	/**
	 * @author mh
	 */
	public class Field extends UID implements IField, IDisposable {
		
		protected var _value: *;
		
		private var _observers : ObserverList;
		
		public function Field( value: * = null ) {
			if( value ) {
				setValue( value );
			}
		}
		
		public function get value(): * {
			return _value;
		}
		
		public function addObserver( observer: IFieldObserver, executeImmediately: Boolean = false,
									weakReference: Boolean = false ): Boolean {
			if( !_observers ) {
				_observers = OBSERVER_LIST_POOL.getOrCreate();
			}
			
			var added: Boolean = _observers.add( observer, weakReference );
			
			if( executeImmediately ) {
				observer.onFieldChange( this, null, _value );
			}
			
			return added;
		}
		
		protected function get hasObservers(): Boolean {
			if( _observers ) {
				clearObservers();
			}
			return _observers != null;
		}

		public function removeObserver( observer: IFieldObserver ): Boolean {
			if( _observers && _observers.remove( observer ) ) {
				clearObservers();
				return true;
			} else {
				return false;
			}
		}
		
		private function clearObservers() : void {
			if( _observers.empty ) {
				OBSERVER_LIST_POOL.returnInstance( _observers );
				_observers = null;
			}
		}
		
		public function hasObserver( observer: IFieldObserver ): Boolean {
			return _observers && _observers.contains( observer );
		}

		public function get isChangeable(): Boolean {
			return true;
		}
		
		public final function set value( value: * ): void {
			setValue( value );
		}
		
		protected final function notifyStateChange(): void {
			notifyValueChange( null, null );
		}
		
		protected function notifyValueChange( oldValue: *, newValue: * ): void {
			if( _observers ) {
				_observers.notifyPropertyChange( this, oldValue, newValue );
			}
		}
		
		public function setValue( value: * ): Boolean {
			if( _value != value ) {
				notifyValueChange( _value, _value = value );
			}
			return true;
		}
		
		public function dispose() : void {
			clearObservers();
			_value = null;
		}
		
		public function toString() : String {
			return "[" + getQualifiedClassName( this ) + " value='" + value + "']";
		}
	}
}