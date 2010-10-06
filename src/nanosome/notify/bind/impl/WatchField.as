// @license@

package nanosome.notify.bind.impl {
	import nanosome.util.access.Accessor;
	import nanosome.util.access.accessFor;
	import nanosome.notify.bind.IWatchField;
	
	
	import nanosome.notify.field.Field;
	import nanosome.notify.observe.IPropertyObserver;
	import nanosome.notify.observe.IPropertyObservable;
	import nanosome.util.ChangedPropertyNode;
	import nanosome.notify.observe.PropertyBroadcaster;
	import nanosome.notify.field.IFieldObserver;
	import nanosome.notify.field.IField;
	
	import nanosome.util.EnterFrame;
	import nanosome.util.EveryNowAndThen;
	import nanosome.util.list.fnc.FunctionList;

	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	
	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public final class WatchField extends Field
					implements IWatchField, IPropertyObserver, IFieldObserver {
		
		private static const PROTECT_FROM_GARBAGE_COLLECTION: Object = {};
		private static const ENTER_FRAME_CHECK_LIST: FunctionList = new FunctionList();
		{
			EnterFrame.add( ENTER_FRAME_CHECK_LIST.execute );
		}
		
		private const _broadcaster: PropertyBroadcaster = new PropertyBroadcaster();
		
		private var _name: String;
		private var _accessor: Accessor;
		private var _parent: *;
		
		private var _childPropertyWatcherMap: Dictionary;
		private var _target: *;
		private var _fullName: String;
		private var _isListening: Boolean;
		
		public function WatchField( target: *, name: String, originalTarget: *, fullName: String, parent: * ) {
			// Reference to parent is IMPORTANT to prevent garbage collection of parent for deep changes
			_parent = parent;
			_fullName = fullName;
			_name = name;
			_target = target;
			_broadcaster.target = originalTarget;
			_accessor = accessFor( target );
			_value = _accessor.read( target, _name );
			checkListeners();
		}
		
		override public function dispose(): void {
			_broadcaster.dispose();
			removeListeners();
			_childPropertyWatcherMap = null;
			_target = null;
			_accessor = null;
			_parent = null;
			super.dispose();
		}
		
		public function set target( target: * ): void {
			if( _target != target ) {
				removeListeners();
				
				_target = target;
				_accessor = accessFor( target );
				
				if( !_target ) {
					internalValue = null;
				} else {
					check();
				}
				
				checkListeners();
			}
		}
		
		override public function setValue( value: * ): Boolean {
			if( _accessor.write( _target, _name, value ) ) {
				check();
				return true;
			} else {
				return false;
			}
		}
		
		private function set internalValue( newValue: * ): void {
			if( _value != newValue ) {
				if( _childPropertyWatcherMap ) {
					for( var changeWatcher: * in _childPropertyWatcherMap )
						WatchField( changeWatcher ).target = newValue;
				}
				var oldValue: * = _value;
				_value = newValue;
				notifyValueChange( oldValue, newValue );
				_broadcaster.notifyPropertyChange( _fullName, oldValue, newValue );
			}
		}
		
		public function property( name: String ): WatchField {
			if( !_childPropertyWatcherMap ) {
				_childPropertyWatcherMap = new Dictionary( true );
			} else {
				for( var propertyWatcher: * in _childPropertyWatcherMap ) {
					if( WatchField( propertyWatcher )._name == name ) {
						return propertyWatcher;
					}
				}
			}
			propertyWatcher = new WatchField( _value, name, _broadcaster.target, _fullName + "." + name, this );
			_childPropertyWatcherMap[ propertyWatcher ] = true;
			checkListeners();
			EveryNowAndThen.add( checkPropertyWatcher );
			return propertyWatcher;
		}
		
		private function checkPropertyWatcher(): void {
			for( var watcher: * in _childPropertyWatcherMap ) {
				watcher; // To remove warning in FDT
				return;
			}
			_childPropertyWatcherMap = null;
			checkListeners();
		}
		
		private function checkListeners(): void {
			var needsListening: Boolean = ( !_broadcaster.empty || _childPropertyWatcherMap );
			if( _isListening != needsListening ) {
				if( needsListening ) {
					PROTECT_FROM_GARBAGE_COLLECTION[ uid ] = this;
					addListeners();
				} else {
					delete PROTECT_FROM_GARBAGE_COLLECTION[ uid ];
					removeListeners();
				}
			}
		}
		
		public function lock(): void {
			locked = true;
		}
		
		public function unlock(): void {
			locked = false;
		}
		
		public function get locked(): Boolean {
			return _broadcaster.locked;
		}
		
		public function set locked( locked: Boolean ): void {
			_broadcaster.locked = locked;
		}
		
		public function addPropertyObserver( observer: IPropertyObserver ): Boolean {
			if( _broadcaster.add( observer ) ) {
				checkListeners();
				return true;
			}
			return false;
		}
		
		public function removePropertyObserver( observer: IPropertyObserver ): Boolean {
			if( _broadcaster.remove( observer ) ) {
				checkListeners();
				return true;
			}
			return false;
		}
		
		private function addListeners(): void {
			_isListening = true;
			if( _target is IField ) {
				IField( _target ).addObserver( this );
			} else if( _accessor.isBindable( _name ) ) {
				IEventDispatcher( _target ).addEventListener( "propertyChange", 
					onPropertyChanged );
			} else if( _target is IPropertyObservable && _accessor.isObservable( _name ) ) {
				IPropertyObservable( _target ).addPropertyObserver( this );
			} else {
				ENTER_FRAME_CHECK_LIST.add( check );
			}
		}
		
		private function removeListeners(): void {
			_isListening = false;
			if( _target is IField ) {
				IField( _target ).removeObserver( this );
			} else if( _accessor.isBindable( _name ) ) {
				IEventDispatcher( _target ).removeEventListener( "propertyChange", 
					onPropertyChanged );
			} else if( _target is IPropertyObservable && _accessor.isObservable( _name ) ) {
				IPropertyObservable( _target ).removePropertyObserver( this );
			} else {
				ENTER_FRAME_CHECK_LIST.remove( check );
			}
		}
		
		private function onPropertyChanged( event: * ): void {
			// The event will be of type PropertyChangeEvent. But if it would be
			// linked to that type there would be unnecessary requirement to the
			// Flex framework, so that should be kept untyped!
			if( event["property"] == _name ) {
				internalValue = event["newValue"];
			}
		}
		
		public function onPropertyChange( observable: *, propertyName: String, oldValue: *, newValue: * ): void {
			if( propertyName == _name ) {
				internalValue = newValue;
			}
		}
		
		public function onManyPropertiesChanged( observable: *, changes: ChangedPropertyNode ): void {
			var current: ChangedPropertyNode = changes;
			while( current ) {
				if( current.name == _name ) {
					internalValue = current.newValue;
					return;
				}
				current = current.next;
			}
		}
		
		public function onFieldChange( mo: IField, oldValue: * = null, newValue: * = null ): void {
			// We don't know which property changed, but whe know it might
			// have changed.
			check();
		}
		
		private function check(): void {
			var newValue: * = _accessor.read( _target, _name );
			if( _value != newValue ) {
				internalValue = newValue;
			}
		}
		
		public function get path(): String {
			return _fullName;
		}
		
		public function get lastSegment(): String {
			return _name;
		}
		
		public function get object(): * {
			return _broadcaster.target;
		}
		
		override public function toString(): String {
			return "[WatchField (" + _broadcaster.target + ")." + _fullName + "]";
		}
	}
}
