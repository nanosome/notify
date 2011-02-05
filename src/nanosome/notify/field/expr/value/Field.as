package nanosome.notify.field.expr.value {

	
	/**
	 * @author mh
	 */
	public class Field implements IValue {
		
		private var _fieldName: String;
		private var _requiredFields: Array;
		
		public function Field( field: String ) {
			_fieldName = field;
			_requiredFields = [ field ];
		}
		
		public function getValue( base: Number = 0.0, dpi: Number = 0.0,
									fontBase: Number = 0.0, xSize: Number = 0.0,
									fields: Object = null  ): Number {
			return fields[ _fieldName ] || 0;
		}
		
		public function get requiredFields(): Array {
			return _requiredFields;
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
			return false;
		}
	}
}
