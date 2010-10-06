// @license@

package nanosome.notify.field.bool {
	import nanosome.notify.field.IBoolField;
	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public function not( bool: IBoolField ): NotWrapper {
		return new NotWrapper( bool );
	}
}
