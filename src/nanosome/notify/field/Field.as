// @license@ 
package nanosome.notify.field {
	
	
	import nanosome.util.list.fnc.FUNCTION_LIST_POOL;
	import nanosome.util.list.fnc.FunctionList;
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
		
		private var _observers: ObserverList;
		private var _functions: FunctionList;
		
		public function Field( value: * = null ) {
			if( value !== null && value !== undefined ) {
				setValue( value );
			}
		}
		
		public final function set value( value: * ): void {
			setValue( value );
		}
		
		public function setValue( value: * ): Boolean {
			if( _value != value || ( value is Number && isNaN(value) && isNaN(_value) ) ) {
				notifyValueChange( _value, _value = value );
			}
			return true;
		}
		
		public function get value(): * {
			return _value;
		}
		
		public function listen( func: Function, executeImmediatly: Boolean = false,
								weakReference: Boolean=false ): Boolean {
			var hadObservers: Boolean = false;
			if( !_functions ) {
				_functions = FUNCTION_LIST_POOL.getOrCreate();
				hadObservers = _observers != null;
			} else {
				hadObservers = true;
			}
			
			var added: Boolean = _functions.add( func );
			if( executeImmediatly ) {
				func( this, null, _value );
			}
			
			if( !added ) {
				clearFunctions();
			} else if( !hadObservers && hasObservers ) {
				onHasObserver();
			}
			
			return added;
		}
		
		public function addObserver( observer: IFieldObserver, executeImmediately: Boolean = false,
									weakReference: Boolean = false ): Boolean {
			var hadObservers: Boolean = false;
			if( !_observers ) {
				_observers = OBSERVER_LIST_POOL.getOrCreate();
				hadObservers = _functions != null;
			} else {
				hadObservers = true;
			}
			
			var added: Boolean = _observers.add( observer, weakReference );
			if( executeImmediately ) {
				observer.onFieldChange( this, null, _value );
			}
			
			if( !added ) {
				clearObservers();
			} else if( !hadObservers && hasObservers ) {
				onHasObserver();
			}
			
			return added;
		}
		
		public function unlisten( func: Function ): Boolean {
			if( _functions ) {
				if ( _functions.remove( func ) ) {
					if( !hasObservers ) onHasNoObserver();
					return true;
				} else {
					return false;
				}
			} else {
				return false;
			}
		}
		
		public function removeObserver( observer: IFieldObserver ): Boolean {
			if( _observers ) {
				if( _observers.remove( observer ) ) {
					if( !hasObservers ) onHasNoObserver();
					return true;
				} else {
					return false;
				}
			} else {
				return false;
			}
		}
		
		protected function get hasObservers(): Boolean {
			if( _observers ) {
				clearObservers();
			}
			if( _functions ) {
				clearFunctions();
			}
			return _observers != null || _functions != null;
		}
		
		private function clearObservers(): void {
			if( _observers.empty ) {
				OBSERVER_LIST_POOL.returnInstance( _observers );
				_observers = null;
			}
		}
		
		private function clearFunctions(): void {
			if ( _functions.empty ) {
				FUNCTION_LIST_POOL.returnInstance( _functions );
				_functions = null;
			}
		}
		
		public function dispose(): void {
			if( _functions ) {
				FUNCTION_LIST_POOL.returnInstance( _functions );
				_functions = null;
			}
			if( _observers ) {
				OBSERVER_LIST_POOL.returnInstance( _observers );
				_observers = null;
			}
			onHasNoObserver();
			value = null;
		}
		
		public function toString() : String {
			return "[" + getQualifiedClassName( this ) + " value='" + value + "']";
		}
		
		public function hasObserver( observer: IFieldObserver ): Boolean {
			return _observers && _observers.contains( observer );
		}
		
		public function get isChangeable(): Boolean {
			return true;
		}
		
		public function hasListening(func : Function) : Boolean {
			return _functions && _functions.contains(func);
		}
		
		/**
		 * Template method to be called if, for what reason soever, there are no
		 * observers anymore.
		 */
		protected function onHasNoObserver(): void {}
		protected function onHasObserver(): void {}
		
		protected function notifyStateChange(): void {
			notifyValueChange( _value, _value );
		}
		
		protected function notifyValueChange( oldValue: *, newValue: * ): void {
			var hasObserver: Boolean = false;
			var hadObserver: Boolean = false;
			if( _observers ) {
				hadObserver = true;
				_observers.notifyPropertyChange( this, oldValue, newValue );
				if( !_observers.empty ) {
					hasObserver = true;
				}
			}
			if( _functions ) {
				hadObserver = true;
				_functions.execute( this, oldValue, newValue );
				if( !_functions.empty ) {
					hasObserver = true;
				}
			}
			if( hadObserver && !hasObserver ) {
				// hasObservers will also clean all values, could be used different
				// but this way its faster
				hasObservers;
				onHasNoObserver();
			}
		}
	}
}