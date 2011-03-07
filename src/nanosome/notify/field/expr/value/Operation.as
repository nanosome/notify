// @license@ 
package nanosome.notify.field.expr.value {
	
	import nanosome.notify.field.expr.operator.IOperator;
	import nanosome.util.mergeArrays;
	
	/**
	 * Classic operation that consists of two operands and an operator.
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @version 1.0
	 */
	public final class Operation implements IValue {
		
		/**
		 * Operand <code>a</code> for the operation
		 */
		public var a: IValue;
		
		/**
		 * Operand <code>b</code> for the operation
		 */
		public var b: IValue;
		
		/**
		 * Operation implementation that takes <code>a</code> and <code>b</code>
		 * and does the operation.
		 */
		public var operator: IOperator;
		
		// List of the required fields
		private var _requiredFields: Array;
		
		public function Operation() {
			super();
		}
		
		/**
		 * @inheritDoc
		 */
		public function getValue( base: Number = 0.0, dpi: Number = 0.0,
									fontBase: Number = 0.0, xSize: Number = 0.0,
									fields: Object = null ): Number {
			return operator.operate(
				a.getValue( base, dpi, fontBase, xSize, fields ),
				b.getValue( base, dpi, fontBase, xSize, fields )
			);
		}
		
		/**
		 * @inheritDoc
		 */
		public function get requiredFields(): Array {
			if( !_requiredFields ) {
				_requiredFields = mergeArrays( a.requiredFields, b.requiredFields );
			}
			return _requiredFields;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get requiresBase(): Boolean {
			return a.requiresBase || b.requiresBase;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get requiresFontSize(): Boolean {
			return a.requiresFontSize || b.requiresFontSize;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get requiresDPI(): Boolean {
			return a.requiresDPI || b.requiresDPI;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get isStatic(): Boolean {
			return false;
		}
	}
}
