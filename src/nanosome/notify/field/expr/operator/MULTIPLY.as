// @license@ 
package nanosome.notify.field.expr.operator {

	/**
	 * Multipies operand a by operand b.
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @version 1.0
	 */
	public const MULTIPLY: IOperator = new MultiplyOperator();
	
}

import nanosome.notify.field.expr.operator.IOperator;
final class MultiplyOperator implements IOperator {
	
	public function operate( a: Number, b: Number ): Number {
		return a * b;
	}
}