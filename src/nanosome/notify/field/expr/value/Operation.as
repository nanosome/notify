package nanosome.notify.field.expr.value {
	
	import nanosome.notify.field.expr.operator.IOperator;
	import nanosome.util.mergeArrays;

	/**
	 * @author mh
	 */
	public class Operation implements IValue {
		public var a: IValue;
		public var b: IValue;
		public var operator: IOperator;
		
		private var _requiredFields: Array;
		
		public function Operation() {
			super();
		}
		
		public function getValue( base: Number = 0.0, dpi: Number = 0.0,
									fontBase: Number = 0.0, xSize: Number = 0.0,
									fields: Object = null ): Number {
			return operator.operate(
				a.getValue( base, dpi, fontBase, xSize, fields ),
				b.getValue( base, dpi, fontBase, xSize, fields )
			);
		}
		
		public function get requiredFields() : Array {
			if( !_requiredFields ) {
				_requiredFields = mergeArrays( a.requiredFields, b.requiredFields );
			}
			return _requiredFields;
		}
		
		public function get requiresBase() : Boolean {
			return a.requiresBase || b.requiresBase;
		}
		
		public function get requiresFontSize() : Boolean {
			return a.requiresFontSize || b.requiresFontSize;
		}
		
		public function get requiresDPI() : Boolean {
			return a.requiresDPI || b.requiresDPI;
		}
		
		public function get isStatic() : Boolean {
			return false;
		}
	}
}
