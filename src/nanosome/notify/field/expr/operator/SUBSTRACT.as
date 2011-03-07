// @license@ 
package nanosome.notify.field.expr.operator {

	/**
	 * Substracts operand b from operand a.
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @version 1.0
	 */
	public const SUBSTRACT: IOperator = new SubstractOperator();
}

import nanosome.notify.field.expr.operator.IOperator;
final class SubstractOperator implements IOperator {
		
	public function operate( a: Number, b: Number ): Number {
		return a - b;
	}
}
