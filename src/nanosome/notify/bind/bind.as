// @license@
package nanosome.notify.bind {
	
	import nanosome.notify.field.IField;
	import nanosome.notify.bind.impl.BINDER;
	
	/**
	 * <code>bind</code> interconnect s two properties of objects.
	 * 
	 * <p>The change of one property will automatically change the other
	 * property.</p>
	 * 
	 * <p>This code relies internally heavy on the functionality of <code>watch</code>
	 * please refer to watch to learn about possible performance problems.</p>
	 * 
	 * <p>Most of the implementation of binding is handled by <code>FieldBinder</code>,
	 * a util to bind two <code>Field</code>s together, please refer to its documentation
	 * for more information about the implementation.</p> 
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @param objectA object from which a path should be bound (master if uni-directional)
	 * @param pathA path that should be bound
	 * @param objectB object from which a path should be bound
	 * @param pathB path that should be bound
	 * @param bidirectional <code>true</code> if both should be notified of changes
	 * 			of each other
	 * @return <code>IWatchField</code> for objectA.pathA.
	 * @see nanosome.notify.bind.impl#BINDER
	 * @see nanosome.notify.bind.impl.FieldBinder
	 * @see nanosome.notify.bind#watch()
	 * @version 1.0
	 */
	public function bind( objectA: *, pathA: String, objectB: *, pathB: String, bidirectional: Boolean = true ): IField {
		return BINDER.bind( watch( objectA, pathA ), watch( objectB, pathB ), bidirectional );
	}
}
