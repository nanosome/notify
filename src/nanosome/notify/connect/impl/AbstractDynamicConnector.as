package nanosome.notify.connect.impl {
	import nanosome.notify.field.IField;
	import nanosome.notify.field.IFieldObserver;
	import nanosome.notify.observe.IPropertyObservable;
	import nanosome.notify.observe.IPropertyObserver;
	import nanosome.util.ChangedPropertyNode;
	import nanosome.util.EnterFrame;
	import nanosome.util.ILockable;
	import nanosome.util.UID;
	import nanosome.util.access.Accessor;
	import nanosome.util.access.Changes;
	import nanosome.util.access.DELETED;
	import nanosome.util.cleanObject;
	import nanosome.util.pool.IInstancePool;
	import nanosome.util.pool.WeakDictionary;
	import nanosome.util.pool.poolFor;

	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	internal class AbstractDynamicConnector extends UID implements IPropertyObserver, IConnector, IFieldObserver {
		
		protected static const objPool: IInstancePool = poolFor( Object );
		protected static const weakPool: IInstancePool = WeakDictionary.POOL;
		protected static const changePool: IInstancePool = poolFor( ChangedPropertyNode );
		
		private static const EMPTY_OBJECT: Object = {};
		
		protected var _objectA: Object;
		protected var _objectB: Object;
		
		protected var _cacheA: Object;
		protected var _cacheB: Object;
		
		protected var _checkA: Array;
		protected var _checkB: Array;
		
		protected var _mapping: MapInformation;
		protected var _mappingInv: MapInformation;
		
		private var _updateImmediatly: Boolean;
		private var _fieldReferences: WeakDictionary;
		
		public function AbstractDynamicConnector() {
			super();
		}
		
		public function init( objectA: Object, objectB: Object, mapping: MapInformation ): IConnector {
			
			_mapping = mapping;
			_mappingInv = mapping.inverted;
			
			_objectA = objectA;
			_objectB = objectB;
			
			
			if( ( _checkA = mapping.nonEventSending ) || mapping.source.isDynamic ) {
				_cacheA = createCache( objectA, "a", _checkA, mapping.source );
			}
			if( ( _checkB = _mappingInv.nonEventSending ) || mapping.target.isDynamic ) {
				_cacheB = createCache( objectB, "b", _checkB, mapping.target );
			}
			
			if( !_cacheA && _cacheB ) {
				// Invert the objects for sake of simplicity
				// So: if one of two is dynamic, always the first is
				_cacheA = _cacheB;
				_cacheB = null;
				_mapping = _mappingInv;
				_mappingInv = _mapping.inverted;
			}
			
			// Start syncing
			if( _cacheA ) {
				var changes: Changes;
				if( _cacheB ) {
					var property: String;
					var targetProperty: String;
					var oldValue: *;
					var map: Object = _mapping.propertyMap;
					for( property in _cacheA ) {
						targetProperty = map[ property ] || property;
						oldValue = _cacheB[ targetProperty ];
						var newValue: * = _cacheA[ property ];
						if( oldValue != newValue ) {
							if( !changes ) {
								changes = Changes.POOL.getOrCreate();
							}
							changes.oldValues[ targetProperty ] = oldValue;
							changes.newValues[ targetProperty ] = newValue;
							_cacheB[ targetProperty ] = newValue;
						}
					}
					map = _mappingInv.propertyMap;
					for( property in _cacheB ) {
						targetProperty = map[ property ] || property;
						if( !_objectA.hasOwnProperty( targetProperty ) ) {
							changes.oldValues[ targetProperty ] = _cacheB[ property ];
							changes.newValues[ targetProperty ] = DELETED;
							delete _cacheB[ property ];
						}
					}
				}
				if( changes ) {
					applyChanges( changes, _objectA, _cacheA, _objectB, _cacheB,
									mapping, "a", "b" );
				}
				
			}
			var notChanged: Array = mapping.copyAll( _objectA, _objectB );
			if( notChanged ) {
				var i: int = notChanged.length;
				while( --i-(-1) ) {
					property = notChanged[ i ];
					mapping.source.write( _objectA, property, 0 );
				}
			}
			
			if( _cacheA ) {
				EnterFrame.add( compareCacheWithReality );
			}
			
			addRemoveObservers( _objectA, _mapping );
			addRemoveObservers( _objectB, _mappingInv );
			return this;
		}
		
		
		private function addRemoveObservers( obj: *, mapping: MapInformation = null ): void {
			if( mapping && mapping.hasObservable ) {
				IPropertyObservable( obj ).addPropertyObserver( this, weak );
			} else if( obj is IPropertyObservable ) {
				IPropertyObservable( obj ).removePropertyObserver( this );
			}
			if( mapping && mapping.hasBindable ) {
				IEventDispatcher( obj ).addEventListener( "propertyChange", onChangeEvent, false, 0, weak );
			} else if( obj is IEventDispatcher ) {
				IEventDispatcher( obj ).removeEventListener( "propertyChange", onChangeEvent );
			}
		}
		
		public function dispose(): void {
			if( _cacheA ) {
				cleanObject( _cacheA );
				objPool.returnInstance( _cacheA );
				_cacheA = null;
			}
			if( _cacheB ) {
				cleanObject( _cacheB );
				objPool.returnInstance( _cacheB );
				_cacheB = null;
			}
			_checkA = null;
			_checkB = null;
			_objectA = null;
			_objectB = null;
			
			EnterFrame.remove( compareCacheWithReality );
		}
		
		protected function createCache( object: *, idBase: String, nonEventSending: Array, accessor: Accessor ): Object {
			var cache: Object = accessor.readAll( object, nonEventSending );
			
			var property: String;
			for( property in cache ) {
				var value: * = cache[ property ];
				if( value is IField ) {
					addField( value, idBase + property );
				}
			}
			
			return cache;
		}
		
		protected function compareCacheWithReality(): void {
			var changesA: Changes = _mapping.source.updateStorage( _objectA, _cacheA, _checkA );
			var changesB: Changes = null;
			
			if( _cacheB )
				changesB = _mapping.target.updateStorage( _objectB, _cacheB, _checkB );
			
			if( changesA )
				applyChanges( changesA, _objectA, _cacheA, _objectB, _cacheB,
								_mapping, "a", "b", changesB );
			
			if( changesB )
				applyChanges( changesB, _objectB, _cacheB, _objectA, _cacheA,
								_mappingInv, "b", "a" );
		}
		
		private function applyChanges( changes: Changes,
												source: *, cache: Object,
												target: *, targetCache: Object,
												mapping: MapInformation, idBase: String,
												targetIDbase: String,
												otherChanges: Changes = null ): void {
			var unlock: Boolean = false;
			if( target is ILockable ) {
				const lockableB: ILockable = ILockable( target );
				if( !lockableB.locked ) {
					lockableB.lock();
					unlock = true;
				}
			}
			
			const sourceAccess: Accessor = mapping.source;
			const targetAccess: Accessor = mapping.target;
			const map: Object = mapping.propertyMap || EMPTY_OBJECT;
			for( var property: String in changes.newValues ) {
				
				var targetProperty: String = map[ property ] || property;
				
				if( otherChanges ) {
					delete otherChanges.newValues[ targetProperty ];
					delete otherChanges.oldValues[ targetProperty ];
				}
				
				var newValue: * = changes.newValues[ property ];
				var oldValue: * = changes.oldValues[ property ];
				
				// Remove any old field
				if( oldValue is IField ) {
					removeField( oldValue, idBase + property );
				}
				
				if( targetCache ) {
					oldValue = targetCache[ targetProperty ];
					if( oldValue is IField ) {
						removeField( oldValue, targetIDbase + property );
					}
				}
				
				var sourceSuccess: Boolean = true;
				if( newValue === DELETED ) {
					targetAccess.remove( target, targetProperty );
				} else {
					if( !targetAccess.write( target, targetProperty, newValue ) ) {
						if( sourceAccess.write( source, property, 0 ) ) {
							sourceSuccess = true;
						} else {
							sourceSuccess = false;
							// warning?
						}
					}
					
					targetCache[ targetProperty ] = newValue;
					cache[ property ] = newValue;
					
					if( newValue is IField ) {
						if( sourceSuccess ) {
							addField( newValue, idBase + property );
						}
						addField( newValue, targetIDbase + targetProperty );
					}
				}
			}
			
			if( unlock ) {
				lockableB.unlock();
			}
			
			changePool.returnInstance( changes );
		}
		
		private function addField( field: IField, id: String ): void {
			if( !_fieldReferences ) {
				_fieldReferences = weakPool.getOrCreate();
			}
			var references: Object = _fieldReferences[ field ];
			if( !references ) {
				references = _fieldReferences[ field ] = objPool.getOrCreate();
				field.addObserver( this );
			}
			references[ id ] = true;
		}
		
		private function removeField( field: IField, id: String ): void {
			if( _fieldReferences ) {
				var references: Object = _fieldReferences[ field ];
				if( references && references.hasOwnProperty( id ) ) {
					delete references[ id ];
					for( var any: * in references ) {
						return;
					}
					objPool.returnInstance( references );
					field.removeObserver( this );
					delete _fieldReferences[ field ];
					for( any in _fieldReferences ) {
						return;
					}
					weakPool.returnInstance( _fieldReferences );
					_fieldReferences = null;
				}
			}
		}
		
		public function get weak(): Boolean {
			return false;
		}
		
		public function get onEnterFrame() : Boolean {
			return _updateImmediatly;
		}
		
		public function set onEnterFrame( update: Boolean ): void {
			_updateImmediatly = update;
		}
		
		public function onFieldChange( field: IField, oldValue: * = null, newValue: * = null ): void {
		}
		
		
		private function onChangeEvent( e: Event ): void {
			onPropertyChange( e["target"], e["property"], e["oldValue"], e["newValue"] );
		}
		
		public function onPropertyChange( observable: *, propertyName: String, oldValue: *, newValue: * ): void {
			var map: MapInformation;
			var source: * = observable;
			var target: *;
			if( _objectA == observable ) {
				map = _mapping;
				target = _objectB;
			} else {
				map = _mappingInv;
				target = _objectA;
			}
			
			var targetPropertyName: String = map.propertyMap[ propertyName ];
			if( targetPropertyName ) {
				if( !map.target.write( target, targetPropertyName, newValue ) ) {
					map.source.write( source, propertyName, map.target.read( target, targetPropertyName ) );
				}
			}
		}
		
		public function onManyPropertiesChanged( observable: *, changes: ChangedPropertyNode ): void {
			var map: MapInformation;
			var target: *;
			if( _objectA == observable ) {
				map = _mapping;
				target = _objectB;
			} else {
				map = _mappingInv;
				target = _objectA;
			}
			var notChanged: Array = map.target.writeAllByNodes( target, changes, map.propertyMap );
			if( notChanged ) {
				var i: int = notChanged.length;
				while( --i-(-1) ) {
					var property: String = notChanged[ i ];
					map.source.write( observable, property, 0 );
				}
			}
		}
	}
}
