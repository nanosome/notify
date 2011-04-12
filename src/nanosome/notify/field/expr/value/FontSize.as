// @license@ 
package nanosome.notify.field.expr.value {
	
	/**
	 * <code>FontSize</code> evaluates a value based to the size of the capital "X".
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @version 1.0
	 */
	public final class FontSize implements IValue {
		
		// Holder for the size in "em"
		private var _sizeInEm: Number;
		
		/**
		 * 
		 */
		public function FontSize( sizeInEm: Number ) {
			_sizeInEm = sizeInEm;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getValue( base: Number = 0.0, dpi: Number = 0.0,
									fontBase: Number = 0.0, xSize: Number = 0.0,
									fields: Object = null ): Number {
			return _sizeInEm * fontBase;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get requiredFields() : Array {
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get requiresBase() : Boolean {
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get requiresFontSize() : Boolean {
			return true;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get requiresDPI() : Boolean {
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get isStatic() : Boolean {
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function equals( value: IValue ): Boolean {
			if( value == this ) {
				return true;
			}
			if( value is FontSize ) {
				return FontSize( value )._sizeInEm == _sizeInEm;
			}
			return false;
		}
	}
}
