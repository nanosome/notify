package nanosome.notify.field.expr.value {

	
	/**
	 * @author mh
	 */
	public class StaticNumber implements IValue {
		
		private static const instanceCache: Object = {};
		
		public static function forValue( value: Number ): StaticNumber {
			var result: StaticNumber = instanceCache[ value ];
			if( !result ) {
				result = instanceCache[ value ] = new StaticNumber( value );
			}
			return result;
		}
		
		public static const ZERO: StaticNumber = forValue( 0.0 );
		public static const NAN: StaticNumber = forValue( NaN );
		public static const INFINITY: StaticNumber = forValue( Infinity );
		public static const MINUS_ONE : StaticNumber = forValue( -1.0 );
		public static const ONE: StaticNumber = forValue( 1.0 );
		
		private var _value : Number;
		
		public function StaticNumber( value: Number ) {
			_value = value;
		}
		
		public function getValue( base: Number = 0.0, dpi: Number = 0.0,
									fontBase: Number = 0.0, xSize: Number = 0.0,
									fields: Object = null ): Number {
			return _value;
		}
		
		public function get requiredFields(): Array {
			return null;
		}
		
		public function get requiresBase(): Boolean {
			return false;
		}
		
		public function get requiresFontSize(): Boolean {
			return false;
		}
		
		public function get requiresDPI(): Boolean {
			return false;
		}
		
		public function get isStatic(): Boolean {
			return true;
		}
	}
}
