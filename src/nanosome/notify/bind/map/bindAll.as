package nanosome.notify.bind.map {
	
	import nanosome.util.access.Accessor;
	import nanosome.util.access.accessFor;
	
	
	
	
	
	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public function bindAll( source: *, target: *, bidirectional: Boolean = true,
								sourceAccessor: Accessor = null,
								targetAccessor: Accessor = null ): void {
		bindAllMapped(
			source, target,
			CLASS_MAPPINGS.getMapping(
				sourceAccessor || accessFor( source ),
				targetAccessor || accessFor( target )
			).propertyMap, bidirectional
		);
	}
}
