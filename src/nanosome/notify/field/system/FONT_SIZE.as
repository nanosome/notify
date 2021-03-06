// @license@ 
package nanosome.notify.field.system {
	
	import nanosome.notify.field.NumberField;
	
	/**
	 * Field that contains the size of "x"(small) in the current font in pixel.
	 * 
	 * <p>Flash is not able to determine this size. A additional external library
	 * needs to modify this value.</p>
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public const FONT_SIZE: NumberField = new NumberField( 13.0 );
}
