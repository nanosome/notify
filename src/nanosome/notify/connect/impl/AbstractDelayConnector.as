package nanosome.notify.connect.impl {
	
	import nanosome.util.ChangedPropertyNode;
	import nanosome.util.EnterFrame;
	import nanosome.util.ILockable;
	import nanosome.util.access.Accessor;
	import nanosome.util.access.PropertyAccess;
	import nanosome.util.cleanObject;

	/**
 * @author Martin Heidegger mh@leichtgewicht.at
 */
	internal class AbstractDelayConnector extends AbstractDynamicConnector {
		
		protected var _changesA: Object;
		protected var _changesB: Object;
		
		public function AbstractDelayConnector() {
			super();
		}
		
		override public function onPropertyChange( observable: *, property: QName, oldValue : *, newValue : *) : void {
			oldValue;
			
			if( !_changesA && !_changesB ) {
				EnterFrame.add( applyChanges );
			}
			
			var localChanges: Object;
			if( observable == _objectA ) {
				localChanges = _changesA || ( _changesA = objPool.getOrCreate() );
			} else {
				localChanges = _changesB || ( _changesB = objPool.getOrCreate() );
			}
			
			localChanges[ property.toString() ] = newValue;
		}
		
		override public function dispose() : void {
			if( _changesA ) {
				cleanObject( _changesA );
				objPool.returnInstance( _changesA );
				_changesA = null;
			}
			if( _changesB ) {
				cleanObject( _changesB );
				objPool.returnInstance( _changesB );
				_changesB = null;
			}
			super.dispose();
		}
		
		override public function onManyPropertiesChanged(observable : *, changes : ChangedPropertyNode) : void {
			
			if( !_changesA && !_changesB ) {
				EnterFrame.add( applyChanges );
			}
			
			var localChanges: Object;
			if( observable == _objectA ) {
				localChanges = _changesA || ( _changesA = objPool.getOrCreate() );
			} else {
				localChanges = _changesB || ( _changesB = objPool.getOrCreate() );
			}
			
			while( changes ) {
				localChanges[ changes.name ] = changes.newValue;
				changes = changes.next;
			}
		}
		
		protected function applyChanges(): void {
			var propName: *;
			var map: Object;
			var accessA: Accessor = _mapping.source;
			var accessB: Accessor = _mapping.target;
			var propA: PropertyAccess;
			var propB: PropertyAccess;
			
			if( _changesA ) {
				
				var unlockB: Boolean = false;
				if( _objectB is ILockable ) {
					const lockableB: ILockable = ILockable( _objectB );
					if( !lockableB.locked ) {
						lockableB.lock();
						unlockB = true;
					}
				}
				
				if( _changesB ) {
					map = _mapping.propertyMap;
					for( propName in _changesA ) {
						propA = accessA.prop( propName );
						propB = accessB.prop( map[ propName ] );
						delete _changesB[ propName ];
						if( !propB.writer.write( _objectB, _changesA[ propName ] ) ) {
							propA.writer.write( _objectA, propB.reader.read( _objectB ) );
						}
						delete _changesA[ propName ];
					}
				}
				
				if( unlockB ) {
					lockableB.unlock();
				}
				
				objPool.returnInstance( _changesA );
				_changesA = null;
			}
			
			if( _changesB ) {
				var unlockA: Boolean = false;
				if( _objectA is ILockable ) {
					const lockableA: ILockable = ILockable( _objectA );
					if( !lockableA.locked ) {
						lockableA.lock();
						unlockA = true;
					}
				}
				
				map = _mappingInv.propertyMap;
				for( propName in _changesB ) {
					propA = accessA.prop( propName );
					propB = accessB.prop( map[ propName ] );
					if( !propA.writer.write( _objectA, _changesA[ propName ] ) ) {
						propB.writer.write( _objectB, propA.reader.read( _objectA ) );
					}
					delete _changesB[ propName ];
				}
				
				if( unlockA ) {
					lockableA.unlock();
				}
				objPool.returnInstance( _changesB );
				_changesB = null;
			}
			
			
			EnterFrame.remove( applyChanges );
		}
		
		override public function get onEnterFrame(): Boolean {
			return true;
		}
	}
}
