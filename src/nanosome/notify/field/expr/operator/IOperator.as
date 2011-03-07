// @license@ 
package nanosome.notify.field.expr.operator {

	/**
	 * <code>IOperator</code> defines operation that can take place in expressions.
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @version 1.0
	 * @see nanosome.notify.field.expr.value.Operation
	 */
	public interface IOperator {
		
		/**
		 * Performs the operation
		 * 
		 * @param a First operand for operation
		 * @param b Second operand for operation
		 * @return result of operation
		 */
		function operate( a: Number, b: Number ): Number;
	}
}
