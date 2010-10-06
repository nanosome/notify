// @license@

package nanosome.notify.bind {
	import nanosome.notify.field.IField;
	import nanosome.notify.bind.impl.BINDER;
	
	/**
	 * Binds two <code>IField</code> instances.
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @param fieldA First field to be bound
	 *             (the value of this <code>IField</code> will be automatically given to second one)
	 * @param fieldB Second field to be bound
	 * @see nanosome.bind#bind()
	 * @see nanosome.bind#unbindMO()
	 * @see nanosome.bind#unbind()
	 */
	public function bindFields( fieldA: IField, fieldB: IField, bidirectional: Boolean = true ): IField {
		return BINDER.bind( fieldA, fieldB, bidirectional );
	}
}
