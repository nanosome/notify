// @license@ 
package nanosome.notify.field.expr.operator {

	/**
	 * Adds operand a to operand b.
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @version 1.0
	 */
	public const ADD: IOperator = new AddOperator();
}

import nanosome.notify.field.expr.operator.IOperator;

final class AddOperator implements IOperator {
		
	public function operate( a: Number, b: Number ): Number {
		return a + b;
	}
}