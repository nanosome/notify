// @license@
package nanosome.notify.field.system {
	
	import flash.system.Capabilities;
	import nanosome.notify.field.NumberField;
	
	/**
	 * Field that contains the Screens DPI
	 * 
	 * <p>Flash is not able to determine the screens DPI properly. So: In case there
	 * is a javascript library or something else that does determine this properly
	 * it can just change this value.</p>
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public const DPI: NumberField = new NumberField( Capabilities.screenDPI );
}
