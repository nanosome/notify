// @license@ 
package nanosome.notify.field.expr.value {

	/**
	 * <code>StaticNumber</code> is a container for a static number parsed by the
	 * <code>ExpressionParser</code>.
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @version 1.0
	 */
	public final class StaticNumber implements IValue {
		
		// Stores all the created instances
		private static const instanceCache: Object = {};
		
		/**
		 * Stores instances of <code>StaticNumber</code> for the passed-in numbers.
		 * 
		 * @param value Value for which the <code>StaticNumber</code> is requested.
		 * @return instance of <code>StaticNumber</code> for the number
		 */
		public static function forValue( value: Number ): StaticNumber {
			if( isNaN( value ) ) {
				// To be safe, any NaN is the same NAN
				return NAN;
			} else {
				var result: StaticNumber = instanceCache[ value ];
				if( !result ) {
					result = instanceCache[ value ] = new StaticNumber( value );
				}
				return result;
			}
		}
		
		// Value for the static number
		private var _value: Number;
		
		public function StaticNumber( value: Number ) {
			_value = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getValue( base: Number = 0.0, dpi: Number = 0.0,
									fontBase: Number = 0.0, xSize: Number = 0.0,
									fields: Object = null ): Number {
			return _value;
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
			return false;
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
			return true;
		}
		
		/**
		 * @inheritDoc
		 */
		public function equals( value: IValue ): Boolean {
			if( value == this ) {
				return true;
			}
			if( value is StaticNumber ) {
				return StaticNumber( value )._value == _value;
			}
			return false;
		}
	}
}
