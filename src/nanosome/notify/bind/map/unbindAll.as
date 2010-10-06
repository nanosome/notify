package nanosome.notify.bind.map {
	import nanosome.notify.bind.unbindField;
	import nanosome.notify.bind.watch;
	import nanosome.util.access.accessFor;
	
	
	
	
	
	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public function unbindAll( object: * ) : void {
		var allProperties: Array = accessFor(object).properties;
		var i: int = allProperties.length;
		while( --i-(-1) ) {
			unbindField( watch( object, allProperties[i] ) );
		}
	}
}
