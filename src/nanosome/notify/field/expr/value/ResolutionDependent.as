// @license@ 
package nanosome.notify.field.expr.value {

	/**
	 * <code>ResolutionDependent</code> evaluates a value based to the screens resolution.
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @version 1.0
	 */
	public final class ResolutionDependent implements IValue {
		
		private var _factor: Number;
		
		public function ResolutionDependent( factor: Number ) {
			_factor = factor;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getValue( base: Number = 0.0, dpi: Number = 0.0,
									fontBase: Number = 0.0, xSize: Number = 0.0,
									fields: Object = null  ): Number {
			return _factor * dpi;
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
			return true;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get requiresFontSize(): Boolean {
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get requiresDPI(): Boolean {
			return true;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get isStatic(): Boolean {
			return false;
		}
	}
}
