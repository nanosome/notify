package nanosome.notify.field.expr {
	import nanosome.notify.bind.bindFields;
	import nanosome.notify.bind.watch;
	import nanosome.notify.field.IField;
	
	/**
	 * @author mh
	 */
	public function bindMapped( objectA: *, pathA: String, objectB: *, pathB: String, expression: String ): IField {
		return bindFields( expr( expression ).field("0", watch( objectA, pathA )), watch( objectB, pathB ) );
	}
}
