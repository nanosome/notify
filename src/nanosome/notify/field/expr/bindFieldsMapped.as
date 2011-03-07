// @license@
package nanosome.notify.field.expr {
	
	import nanosome.notify.bind.bindFields;
	import nanosome.notify.field.IField;
	
	/**
	 * Binds two <code>IField</code>s like <code>bindFields</code> but uses an
	 * expression to pass the value.
	 * 
	 * <p>It uses the place holder <code>{0}</code> for the value of the first
	 * field.</p>
	 * 
	 * <listing>
	 *  var a: NumberField = new NumberField(100);
	 *  var b: NumberField = new NumberField();
	 *  bindFieldsMapped( a, b, "{0}/100" );
	 *  b.y // 1.0
	 * </listing>
	 * 
	 * 
	 * @param fieldA First field to be bound
	 *             (the value of this <code>IField</code> will be automatically given to second one)
	 * @param fieldB Second field to be bound
	 * @param expression Expression used to be map <code>A</code> to <code>B</code>
	 * @param bidirectional <code>true</code> if both should be notified of changes
	 * 			of each other
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @version 1.0
	 * @see nanosome.notify.bind.bind;
	 * @see nanosome.notify.bind.bindFields;
	 * @see nanosome.notify.field.expr.bindFieldsMapped;
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @version 1.0
	 */
	public function bindFieldsMapped( fieldA: IField, fieldB: IField, expression: * ): Expression {
		return bindFields( expr( expression ).field("0", fieldA), fieldB ) as Expression;
	}
}
