// @license@
package nanosome.notify.bind {

	import nanosome.notify.bind.impl.BINDER;
	
	/**
	 * 
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @param objectA object from which a path should be bound
	 * @param pathA path that should be resolved from its bond
	 * @see bind
	 * @see binder
	 */
	public function unbind( objectA: *, pathA: String ): void {
		BINDER.unbind( watch( objectA, pathA ) );
	}
}
