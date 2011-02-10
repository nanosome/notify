// @license@ 
package nanosome.notify.field.expr.operator {

	
	/**
	 * @author mh
	 */
	public class SubstractOperator implements IOperator {
		
		public final function operate( a: Number, b: Number ): Number {
			return a - b;
		}
	}
}
