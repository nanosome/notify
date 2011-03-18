// @license@
package nanosome.notify.bind.impl {
	
	/**
	 * Returns and stores (weak referenced) the <code>PropertyWatchRoot</code>
	 * for watching the changes of properties of an object.
	 * 
	 * @param object the object whichs property you want to watch.
	 * @return The search root for this object;
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @version 1.0
	 */
	public function rootForObject( object: * ): PropertyWatchRoot {
		if( object ) {
			var root: PropertyWatchRoot = _registry[ object ];
			if( !root ) {
				root = _registry[ object ] = new PropertyWatchRoot( object );
			}
			return root;
		} else {
			return _nullWatcher;
		}
	}
}

import nanosome.notify.bind.impl.PropertyWatchRoot;
import flash.utils.Dictionary;

const _registry: Dictionary = new Dictionary( true );
const _nullWatcher: PropertyWatchRoot = new PropertyWatchRoot( null );
