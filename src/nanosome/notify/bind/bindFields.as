// @license@ 
package nanosome.notify.bind {
	import nanosome.notify.field.IField;
	import nanosome.notify.bind.impl.BINDER;
	
	/**
	 * Interconnects two <code>IField</code> instances to update on changes.
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @param fieldA First field to be bound
	 *             (the value of this <code>IField</code> will be automatically given to second one)
	 * @param fieldB Second field to be bound
	 * @return fieldA
	 * @see nanosome.notify.bind#bind()
	 * @see nanosome.notify.bind#unbindMO()
	 * @see nanosome.notify.bind#unbind()
	 */
	public function bindFields( fieldA: IField, fieldB: IField, bidirectional: Boolean = true ): IField {
		return BINDER.bind( fieldA, fieldB, bidirectional );
	}
}
