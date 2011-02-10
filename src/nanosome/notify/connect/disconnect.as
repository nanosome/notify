// @license@ 

package nanosome.notify.connect {
	
	
	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public function disconnect( objectA: *, objectB: * ): Boolean {
		return CONNECTIONS.disconnect( objectA, objectB );
	}
}
