package nanosome.notify.bind.map {
	import nanosome.notify.bind.watch;
	import nanosome.notify.bind.impl.BINDER;
	
	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public function bindAllMapped( source: *, target: *, fieldMap: Object, bidirectional: Boolean = true ): void {
		for( var sourceField: String in fieldMap ) {
			BINDER.bind( watch( source, sourceField), watch( target, fieldMap[ sourceField ] ), bidirectional );
		}
	}
}
