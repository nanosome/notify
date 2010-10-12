// @license@
package nanosome.notify.connect {
	
	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public function connect(source : *, target : *, weak : Boolean = false, onEnterFrame: Boolean = false): Boolean {
		return CONNECTIONS.connect( source, target, weak, onEnterFrame );
	}
}
