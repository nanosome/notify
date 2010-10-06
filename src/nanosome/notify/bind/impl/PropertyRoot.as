// @license@
package nanosome.notify.bind.impl {
	import nanosome.util.access.Accessor;
	import nanosome.util.access.accessFor;
	
	import nanosome.util.UID;
	
	

	import flash.utils.Dictionary;
	
	/**
	 * @author mh
	 */
	public class PropertyRoot extends UID {
		
		private static const _registry: Dictionary = new Dictionary( true );
		private static const _nullWatcher: PropertyRoot = new PropertyRoot( null );
		
		public static function forObject( object: * ): PropertyRoot {
			if( object ) {
				var root: PropertyRoot = _registry[ object ];
				if( !root ) {
					root = _registry[ object ] = new PropertyRoot( object );
				}
				return root;
			} else {
				return _nullWatcher;
			}
		}
		
		private var _propertyWatcherMap: Dictionary;
		private var _accessor: Accessor;
		private var _target: *;
		
		public function PropertyRoot( target: * = null ) {
			_target = target;
		}
		
		public function property( name: String ): WatchField {
			if( !_accessor ) {
				_accessor = accessFor( _target );
			}
			
			if( !_propertyWatcherMap ) {
				_propertyWatcherMap = new Dictionary( true );
			}
			
			// Complex access to make use of weak references.
			for( var propertyWatcher: * in _propertyWatcherMap ) {
				if( WatchField( propertyWatcher ).lastSegment == name ) {
					return propertyWatcher;
				}
			}
			
			propertyWatcher = new WatchField( _target, name,
				_target, name, this );
			
			_propertyWatcherMap[ propertyWatcher ] = true;
			
			return propertyWatcher;
		}
	}
}
