// @license@ 
package nanosome.notify.field.expr {
	
	/**
	 * Wrapper function that allows to create a <code>Expression</code> from
	 * various input methods.
	 * 
	 * <p>This method returns the passed in value if it is a <code>Expression<code>
	 * or creates a new expression. More information in the <code>Expression<code>
	 * documentation.</p>
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @param input Input to base the <code>Expression<code> from
	 * @return <code>Expression<code> instance that calculates the input
	 */
	public function expr( input: * ): Expression {
		if( input is Expression ) {
			return input;
		} else {
			return new Expression( input );
		}
	}
}
