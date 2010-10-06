package nanosome.notify.bind.map {
	
	import nanosome.util.access.Accessor;
	import flex.lang.reflect.Field;

	import flash.utils.Dictionary;
	/**
 * @author Martin Heidegger mh@leichtgewicht.at
 */
	public class MappingStorage extends Field {
		
		private const _routes: Dictionary = new Dictionary();
		
		public function getMapping( source: Accessor, target: Accessor ): IClassMapping {
			if( target == null || source == null ) {
				return null;
			} else {
				var routes: Dictionary = _routes[ source ];
				if( !routes ) {
					_routes[ source ] = routes = new Dictionary();
				}
				return routes[ target ] || addMapping( new AutoMapping( source, target ) );
			}
		}
		
		public function addMapping( mapping: IClassMapping ): IClassMapping {
			var source: Accessor = mapping.source;
			var target: Accessor = mapping.target;
			var routes: Dictionary = _routes[ source ] || ( _routes[ source ] = new Dictionary() );
			routes[ target ] = mapping;
			
			var routeInv: IClassMapping = IClassMapping( _routes && _routes[ target ] && Dictionary( _routes[ target ] )[ source ] );
			if( !routeInv || routeInv.inverted != mapping ) {
				addMapping( mapping.inverted );
			}
			
			return mapping;
		}
		
		public function removeMapping( source: Accessor, target: Accessor ): Boolean {
			var route: IClassMapping = IClassMapping( _routes && _routes[ source ] && Dictionary( _routes[ source ] )[ target ] );
			if( route ) {
				var routes: Dictionary = _routes[ source ];
				delete routes[ target ];
				for( var any: * in routes ) {
					any;
					return true;
				}
				delete _routes[ source ];
				return true;
			} else {
				return false;
			}
		}
	}
}
