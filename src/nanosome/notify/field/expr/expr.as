// @license@ 
package nanosome.notify.field.expr {
	/**
	 * @author mh
	 */
	public function expr( expression: * ): Expression {
		if( expression is Expression ) {
			return expression;
		} else {
			return new Expression( expression );
		}
	}
}
