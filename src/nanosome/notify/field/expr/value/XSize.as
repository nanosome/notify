// @license@ 
package nanosome.notify.field.expr.value {
	
	/**
	 * <code>XSize</code> evaluates a value based to the size of the small "x".
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public final class XSize implements IValue {
		
		private var _factor: Number;
		
		public function XSize( factor: Number ) {
			_factor = factor;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getValue( base: Number = 0.0, dpi: Number = 0.0,
									fontBase: Number = 0.0, xSize: Number = 0.0,
									fields: Object = null ): Number {
			return _factor * xSize;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get requiredFields(): Array {
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get requiresBase(): Boolean {
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get requiresFontSize(): Boolean {
			return true;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get requiresDPI(): Boolean {
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get isStatic(): Boolean {
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function equals( value: IValue ): Boolean {
			if( value == this ) {
				return true;
			}
			if( value is XSize ) {
				return XSize( value )._factor == _factor;
			}
			return false;
		}
	}
}
