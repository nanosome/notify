// @license@ 
package nanosome.notify.field.expr.operator {

	/**
	 * Devides operand a by operand b.
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @version 1.0
	 */
	public const DIVIDE: IOperator = new DivideOperator();
}
import nanosome.notify.field.expr.operator.IOperator;

final class DivideOperator implements IOperator {
	public function operate( a: Number, b: Number ): Number {
		return a / b;
	}
}