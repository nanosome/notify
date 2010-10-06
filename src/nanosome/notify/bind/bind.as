// @license@

package nanosome.notify.bind {
	import nanosome.notify.field.IField;
	import nanosome.notify.bind.impl.BINDER;
	
	
	/**
	 * <code>bind</code> is a util to interconnect two properties of objects to
	 * each other. The change of one property will automatically change the other
	 * property.
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @param objectA object from which a path should be bound
	 * @param pathA path that should be bound
	 * @see bind
	 * @see binder
	 */
	public function bind( objectA: *, pathA: String, objectB: *, pathB: String, bidirectional: Boolean = true ): IField {
		return BINDER.bind( watch( objectA, pathA ), watch( objectB, pathB ), bidirectional );
	}
}
