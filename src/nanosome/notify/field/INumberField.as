// @license@ 
package nanosome.notify.field {
	/**
 * @author Martin Heidegger mh@leichtgewicht.at
 */
	public interface INumberField extends IField {
		
		function get asNumber(): Number;
		function get asInt(): int;
		
	}
}
