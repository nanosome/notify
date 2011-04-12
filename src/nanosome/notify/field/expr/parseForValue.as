package nanosome.notify.field.expr {
	import nanosome.notify.field.expr.value.IValue;

	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public function parseForValue( input: * ): IValue {
		return PARSER.parse( input );
	}
}
