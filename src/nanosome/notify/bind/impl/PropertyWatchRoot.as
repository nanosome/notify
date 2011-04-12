// @license@ 
package nanosome.notify.bind.impl {
	
	import nanosome.util.UID;
	import nanosome.util.access.Accessor;
	import nanosome.util.access.accessFor;
	
	import flash.utils.Dictionary;
	
	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public class PropertyWatchRoot extends UID {
		
		private var _propertyWatcherMap: Dictionary;
		private var _accessor: Accessor;
		private var _target: *;
		
		public function PropertyWatchRoot( target: * = null ) {
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
			
			propertyWatcher = new WatchField( _target, _accessor, name, name, this );
			
			_propertyWatcherMap[ propertyWatcher ] = true;
			
			return propertyWatcher;
		}
	}
}
