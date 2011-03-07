// @license@ 
package nanosome.notify.field.impl {
	
	import nanosome.util.pool.poolFor;
	import nanosome.util.pool.IInstancePool;
	
	/**
	 * Pool for the observers 
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public const OBSERVER_LIST_POOL: IInstancePool = poolFor( ObserverList );
}
