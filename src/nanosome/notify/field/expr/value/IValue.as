// @license@ 
package nanosome.notify.field.expr.value {

	/**
	 * <code>IValue</code> defines a value evaluator in the numeric <code>Expression</code>.
	 * system.
	 * 
	 * @author Martin Heidegger
	 * @version 1.0
	 */
	public interface IValue {
		
		/**
		 * Calculates the value of the expression based to various input parameters.
		 * 
		 * @param base Calculation base for <code>%</code> values
		 * @param dpi Calculation base for natural units(<code>cm</code>,<code>in</code>...) in pixel per inch
		 * @param fontBase Calculation base for <code>em</code> values
		 * @param xSize Calculation base for <code>ex</code> values
		 * @param fields Valueset (<code>String->Number</code>) for the required fields.
		 */
		function getValue( base: Number = 0.0, dpi: Number = 0.0, fontBase: Number = 0.0,
						   xSize: Number = 0.0, fields: Object = null ): Number;
		
		/**
		 * List of names (<code>String</code>) of the fields required for the evaluation.
		 */
		function get requiredFields(): Array;
		
		/**
		 * <code>true</code> if the base is required for the evaluation.
		 */
		function get requiresBase(): Boolean;
		
		/**
		 * <code>true</code> if the font size is required for the evaluation.
		 */
		function get requiresFontSize(): Boolean;
		
		/**
		 * <code>true</code> if the dpi is required for the evaulation.
		 */
		function get requiresDPI(): Boolean;
		
		/**
		 * <code>true</code> if the value is static and nothing will change it.
		 */
		function get isStatic(): Boolean;
	}
}
