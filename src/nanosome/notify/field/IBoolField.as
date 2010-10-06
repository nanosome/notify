// @license@
package nanosome.notify.field {

	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public interface IBoolField extends IField {
		
		function get isTrue(): Boolean;
		function get isFalse(): Boolean;
		
		function yes():Boolean;
		function no():Boolean;
		
		function flip(): Boolean;
	}
}
