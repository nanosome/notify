package nanosome.notify.bind.map {
	import nanosome.util.access.accessFor;
	import nanosome.util.access.Accessor;
	import nanosome.notify.field.Field;
	
	import nanosome.util.invertObject;

	
	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public class MappingStorage extends Field {
		
		private const _maps: Object = new Object();
		
		public function MappingStorage() {
			super();
		}
		
		public function getMapping( source: Accessor, target: Accessor ): Object {
			if( target == null || source == null ) {
				return null;
			} else {
				return _maps[ getId( source, target ) ] || addMappingInternal( source, target, autoMap( source, target ) );
			}
		}
		
		public function addMapping( source: Class, target: Class, mapping: Object ): Boolean {
			if( addMappingInternal( accessFor( source ), accessFor( target ), mapping ) ) {
				notifyStateChange();
				return true;
			} else {
				return false;
			}
		}
		
		private function addMappingInternal( source: Accessor, target: Accessor, mapping: Object ): Object {
			if( mapping ) {
				
				var id: String = getId( source, target );
				var idInv: String = getId( target, source );
				_maps[ id ] = mapping;
				
				var mappingInv: Object = _maps[ idInv ];
				if( !mappingInv || !isInvertedVersion( mappingInv, mapping ) ) {
					_maps[ idInv ] = invertObject( mapping );
				}
				
				return mapping;
			} else {
				return null;
			}
		}
		
		public function removeMapping( source: Accessor, target: Accessor ): Boolean {
			
			var id: String = getId( source, target );
			var idInv: String = getId( target, source );
			if( _maps[ id ] ) {
				delete _maps[ id ];
				delete _maps[ idInv ];
				notifyStateChange();
				return true;
			} else {
				return false;
			}
		}
		
		private function getId( source: Accessor, target: Accessor ): String {
			return source.uid + "x" + target.uid;
		}
		
		private function isInvertedVersion( object: Object, objectInv: Object ): Boolean {
			var property: String;
			for( property in object ) {
				if( property != objectInv[ object[ property ] ] ) {
					return false;
				}
			}
			for( property in objectInv ) {
				if( property != object[ objectInv[ property ] ] ) {
					return false;
				}
			}
			return true;
		}
		
		private function autoMap( source: Accessor, target: Accessor ): Object {
			var propA: Array = source.properties;
			var map: Object = {};
			for each( var propertyName: String in propA ) {
				var typeA: Class = source.getPropertyType( propertyName );
				var typeB: Class = target.getPropertyType( propertyName );
				if( typeA == typeB ) {
					map[ propertyName ] = propertyName;
				}
			}
			return map;
		}
	}
}
