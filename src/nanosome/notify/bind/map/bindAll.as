// @license@ 
package nanosome.notify.bind.map {
	
	import nanosome.util.access.Accessor;
	import nanosome.util.access.accessFor;
	
	/**
	 * 
	 * @param source
	 * @param target
	 * @param bidirectional
	 * @param sourceAccessor
	 * @param targetAccessor 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @version 1.0
	 */
	public function bindAll( source: *, target: *, bidirectional: Boolean = true,
								sourceAccessor: Accessor = null,
								targetAccessor: Accessor = null ): void {
		bindAllMapped(
			source, target,
			CLASS_MAPPINGS.getMapping(
				sourceAccessor || accessFor( source ),
				targetAccessor || accessFor( target )
			), bidirectional
		);
	}
}
