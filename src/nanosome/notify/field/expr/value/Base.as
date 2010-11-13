package nanosome.notify.field.expr.value {

	
	/**
	 * @author mh
	 */
	public class Base implements IValue {

		private var _field : String;
		private var _target : IValue;
		private var _requiredFields : Array;

		public function Base( field: String, target: IValue ) {
			_target = target;
			_field = field;
			_requiredFields = target.requiredFields;
			if( _requiredFields.indexOf( field ) == -1 ) {
				_requiredFields.push( field );
			}
		}

		public function getValue( base: Number = 0.0, dpi: Number = 0.0,
									fontBase: Number = 0.0, xSize: Number = 0.0,
									fields: Object = null  ): Number {
			return _target.getValue( fields[ _field ], dpi, fontBase, xSize, fields);
		}
		
		public function get requiredFields() : Array {
			return _requiredFields;
		}
		
		public function get requiresBase() : Boolean {
			return false;
		}
		
		public function get requiresFontSize() : Boolean {
			return _target.requiresFontSize;
		}
		
		public function get requiresDPI() : Boolean {
			return _target.requiresDPI;
		}
		
		public function get isStatic() : Boolean {
			return _target.isStatic;
		}
	}
}
