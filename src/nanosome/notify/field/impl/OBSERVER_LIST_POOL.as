// @license@
package nanosome.notify.field.impl {
	
	import nanosome.util.pool.InstancePool;
	import nanosome.util.pools;
	
	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public const OBSERVER_LIST_POOL: InstancePool = pools.getOrCreate( ObserverList );
}
