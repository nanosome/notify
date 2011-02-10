// @license@ 
package nanosome.notify.field.expr.value {

	/**
	 * @author mh
	 */
	public interface IValue {
		function getValue( base: Number = 0.0, dpi: Number = 0.0, fontBase: Number = 0.0, xSize: Number = 0.0, fields: Object = null ): Number;
		function get requiredFields(): Array;
		function get requiresBase(): Boolean;
		function get requiresFontSize(): Boolean;
		function get requiresDPI(): Boolean;
		function get isStatic(): Boolean;
	}
}
