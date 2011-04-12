// @license@
package nanosome.notify.bind.impl {
	import nanosome.notify.bind.IWatchField;
	import nanosome.notify.field.Field;
	import nanosome.notify.field.IField;
	import nanosome.notify.field.IFieldObserver;
	import nanosome.notify.observe.IPropertyObservable;
	import nanosome.notify.observe.IPropertyObserver;
	import nanosome.util.ChangedPropertyNode;
	import nanosome.util.EnterFrame;
	import nanosome.util.EveryNowAndThen;
	import nanosome.util.access.Accessor;
	import nanosome.util.access.accessFor;
	import nanosome.util.access.qname;
	import nanosome.util.list.fnc.FunctionList;

	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	/**
	 * 
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @version 1.0
	 */
	public final class WatchField extends Field
					implements IWatchField, IPropertyObserver, IFieldObserver {
		
		
		private static const PROTECT_FROM_GARBAGE_COLLECTION: Object = {};
		
		/**
		 * 
		 */
		private static const ENTER_FRAME_CHECK_LIST: FunctionList = new FunctionList();
		{
			EnterFrame.add( ENTER_FRAME_CHECK_LIST.execute );
		}
		
		private var _accessor: Accessor;
		private var _parent: *;
		
		private var _childPropertyWatcherMap: Dictionary;
		private var _target: *;
		private var _fullPath: String;
		private var _isListening: Boolean;
		
		private var _valueAccessor: Accessor;
		private var _fullName: String;
		private var _qName: QName;
		private var _fullQName: QName;
		
		/**
		 * 
		 */
		public function WatchField( target: *, accessor: Accessor, name: String, fullName: String, parent: * ) {
			// Reference to parent is IMPORTANT to prevent garbage collection of parent for deep changes
			_parent = parent;
			_fullPath = fullName;
			_fullQName = qname( fullName );
			_fullName = name;
			_qName = qname( name );
			_target = target;
			_accessor = accessor;
			_value = _accessor.read( target, _qName );
			checkListeners();
		}
		
		override public function dispose(): void {
			removeListeners();
			_childPropertyWatcherMap = null;
			_target = null;
			_accessor = null;
			_parent = null;
			super.dispose();
		}
		
		public function setTarget( target: *, accessor: Accessor ): void {
			if( _target != target ) {
				removeListeners();
				
				_target = target;
				_accessor = accessor;
				
				if( !_target ) {
					internalValue = null;
				} else {
					check();
				}
				
				checkListeners();
			}
		}
		
		private function set internalValue( newValue: * ): void {
			if( _value != newValue || ( newValue is Number && isNaN(newValue) && isNaN(_value) ) ) {
				if( _childPropertyWatcherMap ) {
					_valueAccessor = accessFor( newValue );
					for( var changeWatcher: * in _childPropertyWatcherMap )
						WatchField( changeWatcher ).setTarget( newValue, _valueAccessor );
				} else {
					_valueAccessor = null;
				}
				var oldValue: * = _value;
				_value = newValue;
				notifyValueChange( oldValue, newValue );
			}
		}
		
		override public function setValue( value: * ): Boolean {
			if( _accessor.write( _target, _qName, value ) ) {
				check();
				return true;
			} else {
				return false;
			}
		}
		
		public function property( name: String ): WatchField {
			if( !_childPropertyWatcherMap ) {
				_childPropertyWatcherMap = new Dictionary( true );
			} else {
				for( var propertyWatcher: * in _childPropertyWatcherMap ) {
					if( WatchField( propertyWatcher )._fullName == name ) {
						return propertyWatcher;
					}
				}
			}
			if( !_valueAccessor ) {
				_valueAccessor = accessFor( _value );
			}
			propertyWatcher = new WatchField( _value, _valueAccessor, name, _fullPath + "." + name, this );
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
			var needsListening: Boolean = ( _childPropertyWatcherMap != null || hasObservers );
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
		
		private function addListeners(): void {
			_isListening = true;
			if( _target is IField ) {
				IField( _target ).addObserver( this );
			} else if( _target is IEventDispatcher && _accessor.isBindable( _fullName ) ) {
				IEventDispatcher( _target ).addEventListener( "propertyChange", 
					onPropertyChanged );
			} else if( _target is IPropertyObservable && _accessor.isObservable( _fullName ) ) {
				IPropertyObservable( _target ).addPropertyObserver( this );
			} else {
				ENTER_FRAME_CHECK_LIST.add( check );
			}
		}
		
		private function removeListeners(): void {
			_isListening = false;
			if( _target is IField ) {
				IField( _target ).removeObserver( this );
			} else if( _target is IEventDispatcher && _accessor.isBindable( _fullName ) ) {
				IEventDispatcher( _target ).removeEventListener( "propertyChange", 
					onPropertyChanged );
			} else if( _target is IPropertyObservable && _accessor.isObservable( _fullName ) ) {
				IPropertyObservable( _target ).removePropertyObserver( this );
			} else {
				ENTER_FRAME_CHECK_LIST.remove( check );
			}
		}
		
		private function onPropertyChanged( event: * ): void {
			// The event will be of type PropertyChangeEvent. But if it would be
			// linked to that type there would be unnecessary requirement to the
			// Flex framework, so that should be kept untyped!
			if( event["property"] == _fullName ) {
				internalValue = event["newValue"];
			}
		}
		
		public function onPropertyChange( observable: *, propertyName: QName, oldValue: *, newValue: * ): void {
			if( propertyName == _qName ) {
				internalValue = newValue;
			}
		}
		
		public function onManyPropertiesChanged( observable: *, changes: ChangedPropertyNode ): void {
			var current: ChangedPropertyNode = changes;
			while( current ) {
				if( current.name == _qName ) {
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
		
		override protected function onHasObserver(): void {
			checkListeners();
		}
		
		override protected function onHasNoObserver(): void {
			checkListeners();
		}
		
		private function check( e: * = null ): void {
			e;
			var newValue: * = _accessor.read( _target, _qName );
			if( _value != newValue ) {
				internalValue = newValue;
			}
		}
		
		public function get path(): String {
			return _fullPath;
		}
		
		public function get lastSegment(): String {
			return _fullName;
		}
		
		public function get object(): * {
			return _target;
		}
		
		override public function toString(): String {
			return "[WatchField(" + _target + ")." + _fullPath + "]";
		}
	}
}
