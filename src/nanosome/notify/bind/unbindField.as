// @license@

package nanosome.notify.bind {
	import nanosome.notify.field.IField;
	import nanosome.notify.bind.impl.BINDER;
	
	
	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public function unbindField( field: IField ): IField {
		return BINDER.unbind( field );
	}
}
