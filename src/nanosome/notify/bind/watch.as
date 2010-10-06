// @license@
package nanosome.notify.bind {
	import nanosome.notify.bind.impl.PropertyRoot;
	import nanosome.notify.bind.impl.WatchField;
	
	/**
	 * @author mh
	 */
	public function watch( object: *, path: String ): IWatchField {
		if( !path ) {
			path = "";
		}
		
		var pathList: Array = path.split( "." );
		var propertyName: String = pathList.shift();
		
		var propertyMO: WatchField = PropertyRoot.forObject( object ).property( propertyName );
		while( propertyName = pathList.shift() ) {
			propertyMO = propertyMO.property( propertyName );
		}
		
		return propertyMO;
	}
}
