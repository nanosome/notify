package nanosome.notify.field.expr.value {

	
	/**
	 * @author mh
	 */
	public class ResolutionDependent implements IValue {
		
		private var _value : Number;
		
		public function ResolutionDependent( value : Number ) {
			_value = value;
		}
		
		public function getValue( base: Number = 0.0, dpi: Number = 0.0,
									fontBase: Number = 0.0, xSize: Number = 0.0,
									fields: Object = null  ): Number {
			return _value * dpi;
		}
		
		public function get requiredFields(): Array {
			return null;
		}
		
		public function get requiresBase(): Boolean {
			return true;
		}
		
		public function get requiresFontSize(): Boolean {
			return false;
		}
		
		public function get requiresDPI(): Boolean {
			return true;
		}
		
		public function get isStatic(): Boolean {
			return false;
		}
	}
}
