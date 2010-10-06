package nanosome.notify.bind.map {
	
	import nanosome.notify.field.IField;
	import nanosome.util.access.Accessor;

	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public class AutoMapping implements IClassMapping {
		
		private var _target: Accessor;
		private var _source: Accessor;
		private var _inverted: AutoMapping;
		
		private var _propertyMap: Object;
		
		private var _isEntirelyDynamic: Boolean = false;
		
		public function AutoMapping( source: Accessor, target: Accessor, propertyMap: Object = null, inverted: AutoMapping = null ) {
			
			_source = source;
			_target = target;
			_isEntirelyDynamic = source.isDynamic && target.isDynamic;
			
			var propertyName: String;
			if( !propertyMap ) {
				var props: Array = null;
				
				if( _source.isDynamic ) {
					if( _target.isDynamic ) {
						props = _source.properties;
					} else {
						props = _target.properties;
					}
				} else {
					props = _source.properties;
				}
				
				if( props ) {
					propertyMap = {};
					var i: int = props.length;
					while( --i-(-1) ) {
						propertyName = props[ i ];
						
						// Target and source should have same properties
						var typeA: Class = _target.getPropertyType( propertyName );
						var typeB: Class = _source.getPropertyType( propertyName );
						if( typeA == typeB || typeA is IField || typeB is IField ) {
							propertyMap[ propertyName ] = propertyName;
						}
					}
				}
			}
			
			_propertyMap = propertyMap;
			
			if( !inverted ) {
				var invertedMap: Object = {};
				for( propertyName in propertyMap ) {
					invertedMap[ propertyMap[ propertyName ] ] = propertyName;
				}
				inverted = new AutoMapping( target, source, invertedMap, this );
			}
			
			_inverted = inverted;
		}
		
		public function get inverted(): IClassMapping {
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
		
		public function get isEntirelyDynamic() : Boolean {
			return _isEntirelyDynamic;
		}
	}
}
