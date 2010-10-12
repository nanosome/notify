package nanosome.notify.connect.impl {
	import nanosome.notify.field.Field;
	import nanosome.notify.field.IField;
	import nanosome.util.access.Accessor;
	import nanosome.util.access.typeMatches;
	import nanosome.util.invertObject;
	

	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public class MapInformation extends Field {
		
		private var _target: Accessor;
		private var _source: Accessor;
		private var _inverted: MapInformation;
		
		private var _isEntirelyDynamic: Boolean = false;
		
		private var _fields: Object;
		private var _propertyMap: *;
		private var _hasBindable: Boolean;
		private var _hasObservable: Boolean;
		private var _nonEvent: Array;
		
		public function MapInformation( source: Accessor, target: Accessor, propertyMapping: Object, inverted: MapInformation = null ) {
			
			_source = source;
			_target = target;
			_isEntirelyDynamic = source.isDynamic && target.isDynamic;
			_inverted = inverted || new MapInformation( target, source, invertObject( propertyMapping ), this );
			
			super( propertyMapping );
		}
		
		
		override protected function notifyValueChange( oldValue: *, newValue: *) : void {
			var properties: Array = null;
			
			if( _source.isDynamic ) {
				if( _target.isDynamic ) {
					properties = _source.properties;
				} else {
					properties = _target.properties;
				}
			} else {
				properties = _source.properties;
			}
			
			_fields = null;
			
			var propertyMap: Object = {};
			var fields: Object;
			var nonEvent: Array;
			_hasBindable = false;
			_hasObservable = false;
			
			for( var propertyName: String in newValue ) {
				var targetProperty: String = newValue[ propertyName ];
				// Target and source should have same properties
				var typeA: Class = _source.getPropertyType( propertyName );
				var typeB: Class = _target.getPropertyType( targetProperty );
				if( typeA is IField && typeB is IField ) {
					( fields || ( fields = {}) )[ propertyName ] = targetProperty;
				}
				if( typeMatches( typeA, typeB ) ) {
					propertyMap[ propertyName ] = targetProperty;
					if( _source.isObservable( propertyName ) ) {
						_hasObservable = true;
					} else if( _source.isBindable( propertyName ) ) {
						_hasBindable = true;
					} else {
						( nonEvent || (nonEvent = []) ).push( propertyName );
					}
				}
			}
			
			_nonEvent = nonEvent;
			_fields = fields;
			_propertyMap = propertyMap;
			super.notifyValueChange(oldValue, newValue);
		}
		
		public function get inverted(): MapInformation {
			return _inverted;
		}
		
		public function get source(): Accessor {
			return _source;
		}
		
		public function get target(): Accessor {
			return _target;
		}
		
		public function get propertyMap(): Object {
			return _propertyMap;
		}
		
		public function get isEntirelyDynamic(): Boolean {
			return _isEntirelyDynamic;
		}
		
		public function get hasBindable(): Boolean {
			return _hasBindable;
		}
		
		public function get hasObservable(): Boolean {
			return _hasObservable;
		}
		
		public function get nonEventSending(): Array {
			return _nonEvent;
		}

		public function get fields() : Object {
			return _fields;
		}
		
		public function copyAll( source: *, target: * ): Array {
			return _target.writeAll( target, _source.readMapped( source, _propertyMap ) );
		}
	}
}
