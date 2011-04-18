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
	import nanosome.util.access.PropertyAccess;
	import nanosome.util.access.qname;
	import nanosome.util.access.refreshStorage;
	import nanosome.util.access.writeAllByNodes;
	import nanosome.util.cleanObject;
	import nanosome.util.pool.IInstancePool;
	import nanosome.util.pool.WeakDictionary;
	import nanosome.util.pool.poolFor;

	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	internal class AbstractDynamicConnector extends UID implements IPropertyObserver, IConnector, IFieldObserver {
		
		protected static const objPool: IInstancePool = poolFor( Object );
		protected static const weakPool: IInstancePool = WeakDictionary.POOL;
		protected static const changePool: IInstancePool = poolFor( ChangedPropertyNode );
		
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
		
		private var _customAProps: Object;
		private var _customBProps: Object;
		
		public function AbstractDynamicConnector() {
			super();
		}
		
		public function init( objectA: Object, objectB: Object, mapping: MapInformation ): IConnector {
			
			_mapping = mapping;
			_mappingInv = mapping.inverted;
			
			_objectA = objectA;
			_objectB = objectB;
			
			
			_checkA = mapping.isEntirelyDynamic ? mapping.source.readAndWritableProperties : _mapping.nonEventSending;
			_cacheA = createCache( objectA, "a", _checkA, mapping.isEntirelyDynamic );
			
			_checkB = mapping.isEntirelyDynamic ? mapping.target.readAndWritableProperties : _mappingInv.nonEventSending;
			_cacheB = createCache( objectB, "b", _checkB, mapping.isEntirelyDynamic );
			
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
								changes = CHANGES_POOL.getOrCreate();
							}
							changes.oldValues[ targetProperty ] = oldValue;
							changes.newValues[ targetProperty ] = newValue;
							_cacheB[ targetProperty ] = newValue;
						}
					}
					map = _mappingInv.propertyMap;
					for( property in _cacheB ) {
						targetProperty = map[ property ] || property;
						if( !_objectA.hasOwnProperty( qname( targetProperty ) ) ) {
							if( !changes ) {
								changes = CHANGES_POOL.getOrCreate();
							}
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
					var target: PropertyAccess = _mapping.target.prop( notChanged[ i ] );
					var source: PropertyAccess = _mappingInv.propertyMap[ target ];
					if( source ) {
						source.writer.write( _objectA, 0 );
					}
				}
			}
			
			if( _cacheA ) {
				EnterFrame.add( compareCacheWithReality );
			}
			
			_customAProps = addRemoveObservers( _objectA, _customAProps, _mapping );
			_customBProps = addRemoveObservers( _objectB, _customBProps, _mappingInv );
			return this;
		}
		
		
		private function addRemoveObservers( obj: *, customEvents:Object, mapping: MapInformation = null ): Object {
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
			var name: String;
			if( customEvents ) {
				for( name in customEvents ) {
					IEventDispatcher( obj ).removeEventListener( name, onEvent );
				}
				customEvents = null;
			}
			if( mapping && mapping.customEvents ) {
				customEvents = mapping.customEvents;
				if( customEvents ) {
					for( name in customEvents ) {
						IEventDispatcher( obj ).addEventListener( name, onEvent, false, 0, weak );
					}
				}
			}
			return customEvents;
		}
		
		private function onEvent( event: Event ): void {
			var source: Object = event.target;
			var target: Object = ( source == _objectA ) ? _objectB : _objectA;
			var mapping: MapInformation = ( source == _objectA ) ? _mapping : _mappingInv;
			var props: Array = mapping.customEvents[ event.type ];
			const l: int = props.length;
			for( var i: int = 0; i < l; ++i ) {
				var prop: PropertyAccess = props[ i ];
				PropertyAccess( mapping.propertyMap[ prop ] ).writer.write( target, prop.reader.read( source ) );
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
			if( _objectA ) addRemoveObservers( _objectA, _customAProps );
			if( _objectB ) addRemoveObservers( _objectB, _customBProps );
			_checkA = null;
			_checkB = null;
			_objectA = null;
			_objectB = null;
			EnterFrame.remove( compareCacheWithReality );
		}
		
		protected function createCache( object: *, idBase: String, fromProperties: Array, addDynamic: Boolean ): Object {
			var cache: Object = {};
			var value: *;
			var property: String;
			var readProperties: Object = objPool.getOrCreate();
			if( fromProperties ) {
				var i: int = fromProperties.length;
				while( --i-(-1) ) {
					var access: PropertyAccess = PropertyAccess( fromProperties[ i ] );
					value = access.reader.read( object );
					readProperties[ access.qName.toString() ] = true;
					if( value is IField ) {
						addField( value, idBase + property );
					}
					cache[ access.qName.toString() ] = value;
				}
			}
			if( addDynamic ) {
				for( property in object ) {
					if( !readProperties[ property ] ) {
						value = object[ property ];
						if( value is IField ) {
							addField( value, idBase + property );
						}
						cache[ property ] = value;
					}
				}
			}
			return cache;
		}
		
		protected function compareCacheWithReality(): void {
			var changesA: Changes = refreshStorage( _objectA, _cacheA, _checkA, _mapping.source );
			var changesB: Changes = null;
			
			if( _cacheB )
				changesB = refreshStorage( _objectB, _cacheB, _checkB, _mapping.target );
			
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
			const map: Dictionary = mapping.propertyMap || EMPTY_OBJECT;
			for( var property: String in changes.newValues ) {
				
				var sourceProperty: PropertyAccess = sourceAccess.prop( property );
				if( sourceProperty ) {
					var targetPropAccess: PropertyAccess = map[ sourceProperty ] || sourceProperty;
					var targetQName: QName = targetPropAccess.qName;
					
					// If two changed for the same value it kinda sucks.
					if( otherChanges ) {
						delete otherChanges.newValues[ targetQName.toString() ];
						delete otherChanges.oldValues[ targetQName.toString() ];
					}
					
					var newValue: * = changes.newValues[ property ];
					var oldValue: * = changes.oldValues[ property ];
					
					// Remove any old field
					if( oldValue is IField ) {
						removeField( oldValue, idBase + property );
					}
					
					if( targetCache ) {
						oldValue = targetCache[ targetQName.toString() ];
						if( oldValue is IField ) {
							removeField( oldValue, targetIDbase + property );
						}
					}
					
					var sourceSuccess: Boolean = true;
					var del: Object = DELETED;
					if( newValue === del ) {
						if( targetPropAccess ) targetPropAccess.writer.remove( target );
					} else {
						if( !targetPropAccess || !targetPropAccess.writer.write( target, newValue ) ) {
							
							if( sourceProperty.writer.write( source, 0 ) ) {
								sourceSuccess = true;
							} else {
								sourceSuccess = false;
								// warning?
							}
						}
						
						targetCache[ targetQName.toString() ] = newValue;
						cache[ property ] = newValue;
						
						if( newValue is IField ) {
							if( sourceSuccess ) {
								addField( newValue, idBase + property );
							}
							addField( newValue, targetIDbase + targetQName.toString() );
						}
					}
				}
			}
			
			if( unlock ) {
				lockableB.unlock();
			}
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
			onPropertyChange( e["target"], qname( e["property"] ), e["oldValue"], e["newValue"] );
		}
		
		public function onPropertyChange( observable: *, propertyName: QName, oldValue: *, newValue: * ): void {
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
			
			var targetProperty: PropertyAccess = map.propertyMap[ map.source.prop( propertyName ) ];
			if( targetProperty && !targetProperty.writer.write( target, newValue ) ) {
				map.source.prop( propertyName ).writer.write(
					source, targetProperty.reader.read( target )
				);
			}
		}
		
		public function onManyPropertiesChanged( observable: *, changedProps: ChangedPropertyNode ): void {
			var map: MapInformation;
			var target: *;
			if( _objectA == observable ) {
				map = _mapping;
				target = _objectB;
			} else {
				map = _mappingInv;
				target = _objectA;
			}
			var notChanged: Array = writeAllByNodes( target, changedProps, map.propertyMap, map.target );
			if( notChanged ) {
				var i: int = notChanged.length;
				while( --i-(-1) ) {
					map.source.prop( notChanged[ i ] ).writer.write( observable, 0 );
				}
			}
		}
	}
}
import nanosome.util.access.Changes;
import nanosome.util.pool.IInstancePool;
import nanosome.util.pool.poolFor;

import flash.utils.Dictionary;

const CHANGES_POOL: IInstancePool = poolFor( Changes );
const EMPTY_OBJECT: Dictionary = new Dictionary();