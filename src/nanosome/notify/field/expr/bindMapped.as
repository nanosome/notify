// @license@ 
package nanosome.notify.field.expr {
	
	import nanosome.notify.bind.bindFields;
	import nanosome.notify.bind.watch;
	
	/**
	 * Binds two paths like <code>bind</code> but uses a expression to pass the value.
	 * 
	 * <p>It uses the place holder <code>{0}</code> for the value of the first
	 * field.</p>
	 * 
	 * <listing>
	 *  var a: Object = {x:100};
	 *  var b: Sprite = new Sprite;
	 *  bindMapped( a, "x", b, "y", "{0}/100" );
	 *  b.y // 1.0
	 * </listing>
	 * 
	 * 
	 * @param objectA object from which a path should be bound (master if uni-directional)
	 * @param pathA path that should be bound
	 * @param objectB object from which a path should be bound
	 * @param pathB path that should be bound
	 * @param expression Expression used to be map <code>A</code> to <code>B</code>
	 * @param bidirectional <code>true</code> if both should be notified of changes
	 * 			of each other
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @version 1.0
	 * @see nanosome.notify.bind.bind;
	 * @see nanosome.notify.bind.bindFields;
	 * @see nanosome.notify.field.expr.bindFieldsMapped;
	 */
	public function bindMapped( objectA: *, pathA: String,
								objectB: *, pathB: String,
								expression: *, bidirectional: Boolean = true ): Expression {
		return bindFields(
			expr( expression )
				.field( "0", watch( objectA, pathA )
			),
			watch( objectB, pathB ), bidirectional
		) as Expression;
	}
}
