package nanosome.notify.connect.impl {
	import nanosome.notify.field.Field;
	import nanosome.notify.field.IField;
	import nanosome.util.access.Accessor;
	import nanosome.util.access.PropertyAccess;
	import nanosome.util.access.readMapped;
	import nanosome.util.access.typeMatches;
	import nanosome.util.access.writeAll;
	import nanosome.util.invertObject;

	import flash.utils.Dictionary;
	

	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public class MapInformation extends Field {
		
		private var _target: Accessor;
		private var _source: Accessor;
		private var _inverted: MapInformation;
		
		private var _isEntirelyDynamic: Boolean = false;
		
		private var _fields: Object;
		private var _propertyMap: Dictionary;
		private var _hasBindable: Boolean;
		private var _hasObservable: Boolean;
		private var _nonEvent: Array;
		private var _syncLock: Boolean;
		
		public function MapInformation( source: Accessor, target: Accessor, propertyMapping: Object, inverted: MapInformation = null ) {
			
			_source = source;
			_target = target;
			_isEntirelyDynamic = source.isDynamic && target.isDynamic;
			_inverted = inverted || new MapInformation( target, source, invertObject( propertyMapping ), this );
			
			super( propertyMapping );
		}
		
		override public function setValue( value: * ): Boolean {
			if( !_syncLock ) {
				return super.setValue( value );
			} else {
				return false;
			}
		}
		
		override protected function notifyValueChange( oldValue: *, newValue: * ): void {
			var propertyMap: Dictionary = new Dictionary();
			var fields: Object = null;
			var nonEvent: Array;
			var events: Object;
			var event: String;
			
			_hasBindable = false;
			_hasObservable = false;
			
			for( var sourceFullName: String in newValue ) {
				var targetFullName: String = newValue[ sourceFullName ];
				// Target and source should have same properties
				var accessA: PropertyAccess = _source.prop( sourceFullName );
				var accessB: PropertyAccess = _target.prop( targetFullName );
				if( accessA && accessB ) {
					if( accessA.type is IField && accessB.type is IField ) {
						( fields || ( fields = {}) )[ sourceFullName ] = targetFullName;
					}
					if( typeMatches( accessA.type, accessB.type ) ) {
						propertyMap[ accessA ] = accessB;
						if( accessA.reader.observable ) {
							_hasObservable = true;
						} else if( accessA.reader.bindable ) {
							_hasBindable = true;
						} else if( ( event = accessA.reader.sendingEvent ) ) {
							var eventPropMapping: Array = ( events || (events = {}) )[ event ];
							if( !eventPropMapping ) {
								eventPropMapping = events[ event ] = [];
							}
							eventPropMapping.push( accessA );
						} else {
							( nonEvent || (nonEvent = []) ).push( accessA );
						}
					} else {
						trace( "!!! Warning: '" + sourceFullName + "' and '" + targetFullName + "' are "
								+ "not of the same type, mapping information will be dismissed!" );
					}
				}
			}
			
			_nonEvent = nonEvent;
			_fields = fields;
			_propertyMap = propertyMap;
			super.notifyValueChange( oldValue, newValue );
			
			if( _inverted ) {
				_syncLock = true;
				_inverted.value = invertObject( newValue );
				_syncLock = false;
			}
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
		
		public function get propertyMap(): Dictionary {
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
			return writeAll( target, readMapped( source, _propertyMap, _source ), _target );
		}
	}
}
