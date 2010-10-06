package nanosome.notify.bind.map {
	
	import nanosome.util.access.Accessor;
	import nanosome.util.access.accessFor;

	/**
	 * Fills the <code>target</code> instance will all properties of the <code>source</code>
	 * property that is passed-in.
	 * 
	 * @param target Instance that should get all the new properties
	 * @param source Instance that holds all the properties
	 * @param targetAccess <code>Accessor</code> to modify the target, if not passed-in
	 *         <code>accessFor(target)</code> will be used to search the Accessor
	 * @param sourceAccess <code>Accessor</code> to read the source, if not passed-in
	 *         <code>accessFor(target)</code> will be used to search the Accessor
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @see accessFor
	 */
	public function pollute( target: *, source: *, targetAccess: Accessor = null,
								sourceAccess: Accessor = null ): void {
		if( !targetAccess ) {
			targetAccess = accessFor( target );
		}
		if( !sourceAccess ) {
			sourceAccess = accessFor( source );
		}
		targetAccess.writeAll( target,
			sourceAccess.readMapped( source, CLASS_MAPPINGS.getMapping( sourceAccess, targetAccess ).propertyMap )
		);
	}
}
