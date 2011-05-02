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
	 * @param bidirectional <code>true</code> if both should be notified of changes
	 * 			of each other
	 * @param clean <code>true</code> to clean former bindings
	 * @return The first field "fieldA" that was passed in.
	 * @see nanosome.notify.bind#bind()
	 * @see nanosome.notify.bind#unbindField()
	 * @see nanosome.notify.bind#unbind()
	 */
	public function bindFields( fieldA: IField, fieldB: IField, bidirectional: Boolean = true, clean: Boolean = false ): IField {
		return BINDER.bind( fieldA, fieldB, bidirectional, clean );
	}
}
