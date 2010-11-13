package nanosome.notify.field.expr.operator {

	
	/**
	 * @author mh
	 */
	public class DivideOperator implements IOperator {
		
		public final function operate( a: Number, b: Number ): Number {
			if( b == 0.0 ) {
				return Infinity;
			}
			return a / b;
		}
	}
}
