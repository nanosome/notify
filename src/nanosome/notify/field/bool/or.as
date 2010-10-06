// @license@

package nanosome.notify.field.bool {
	import nanosome.notify.field.IBoolField;
	
	
	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public function or( ...fields: Array ): IBoolField {
		if( fields.length == 0 ) {
			return FALSE;
		}
		return new OrField( fields );
	}
}
