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
	import nanosome.util.access.PropertyAccess;
	import nanosome.util.access.accessFor;
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
		
		private var _propertyAccessor: PropertyAccess;
		private var _parent: *;
		
		private var _childPropertyWatcherMap: Dictionary;
		private var _target: *;
		private var _fullPath: String;
		private var _isListening: Boolean;
		
		private var _valueAccessor: Accessor;
		private var _name: String;
		private var _qName: QName;
		
		/**
		 * 
		 */
		public function WatchField( target: *, accessor: Accessor, name: QName, parent: * ) {
			// Reference to parent is IMPORTANT to prevent garbage collection of parent for deep changes
			_parent = parent;
			_name = name.toString();
			_qName = name;
			_target = target;
			_propertyAccessor = accessor.prop( _qName );
			_value = _propertyAccessor
				 ? _propertyAccessor.reader.read( target )
				 : null;
			checkListeners();
		}
		
		override public function dispose(): void {
			removeListeners();
			_childPropertyWatcherMap = null;
			_target = null;
			_propertyAccessor = null;
			_parent = null;
			super.dispose();
		}
		
		public function setTarget( target: *, accessor: Accessor ): void {
			if( _target != target ) {
				removeListeners();
				
				_target = target;
				_propertyAccessor = accessor.prop( _qName );
				
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
			if( _propertyAccessor && _propertyAccessor.writer.write( _target, value ) ) {
				check();
				return true;
			} else {
				return false;
			}
		}
		
		public function property( name: QName ): WatchField {
			if( !_childPropertyWatcherMap ) {
				_childPropertyWatcherMap = new Dictionary( true );
			} else {
				for( var propertyWatcher: * in _childPropertyWatcherMap ) {
					if( WatchField( propertyWatcher )._qName == name ) {
						return propertyWatcher;
					}
				}
			}
			if( !_valueAccessor ) {
				_valueAccessor = accessFor( _value );
			}
			propertyWatcher = new WatchField( _value, _valueAccessor, name, this );
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
			var needsListening: Boolean = _propertyAccessor && ( _childPropertyWatcherMap != null || hasObservers );
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
			var event: String;
			if( _target is IField ) {
				IField( _target ).addObserver( this );
				return;
			} else if( _propertyAccessor ) {
				if( _target is IPropertyObservable && _propertyAccessor.reader.observable ) {
					IPropertyObservable( _target ).addPropertyObserver( this );
					return; 
				}
				if( _target is IEventDispatcher ) {
					if( _propertyAccessor.reader.bindable ) {
						IEventDispatcher( _target ).addEventListener( "propertyChange", 
							onPropertyChanged );
						return;
					} else if ( ( event = _propertyAccessor.reader.sendingEvent ) ) {
						IEventDispatcher( _target ).addEventListener( event, check );
						return;
					}
				}
			}
			ENTER_FRAME_CHECK_LIST.add( check );
		}
		
		private function removeListeners(): void {
			_isListening = false;
			var event: String;
			if( _target is IField ) {
				IField( _target ).removeObserver( this );
				return;
			} else if( _propertyAccessor ) {
				if( _target is IPropertyObservable && _propertyAccessor.reader.observable ) {
					IPropertyObservable( _target ).removePropertyObserver( this );
					return; 
				}
				if( _target is IEventDispatcher ) {
					if( _propertyAccessor.reader.bindable ) {
						IEventDispatcher( _target ).removeEventListener( "propertyChange", 
							onPropertyChanged );
						return;
					} else if ( ( event = _propertyAccessor.reader.sendingEvent ) ) {
						IEventDispatcher( _target ).removeEventListener( event, check );
						return;
					}
				}
			}
			ENTER_FRAME_CHECK_LIST.remove( check );
		}
		
		private function onPropertyChanged( event: * ): void {
			// The event will be of type PropertyChangeEvent. But if it would be
			// linked to that type there would be unnecessary requirement to the
			// Flex framework, so that should be kept untyped!
			if( event["property"] == _name ) {
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
			var newValue: * = _propertyAccessor.reader.read( _target );
			if( _value != newValue ) {
				internalValue = newValue;
			}
		}
		
		public function get path(): String {
			return _fullPath;
		}
		
		public function get lastSegment(): QName {
			return _qName;
		}
		
		public function get object(): * {
			return _target;
		}
		
		override public function toString(): String {
			return "[WatchField(" + _target + ")." + _fullPath + "]";
		}
	}
}
