package nanosome.notify.connect.impl {
	import nanosome.notify.bind.map.CLASS_MAPPINGS;
	import nanosome.notify.field.IField;
	import nanosome.notify.field.IFieldObserver;
	import nanosome.util.access.Accessor;
	
	
	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	internal class MapInformationStorage implements IFieldObserver {
		
		private const _stored: Object = {};
		
		public function MapInformationStorage() {
			CLASS_MAPPINGS.addObserver( this );
		}
		
		public function getMap( source: Accessor, target: Accessor ): MapInformation {
			var id: String = source.uid + "x" + target.uid;
			var map: MapInformation = _stored[ id ];
			if( !map ) {
				map = new MapInformation( source, target, CLASS_MAPPINGS.getMapping( source, target ) );
				_stored[ id ] = map;
				_stored[ target.uid + "x" + source.uid ] = map.inverted;
			}
			return map;
		}
		
		public function onFieldChange( field: IField, oldValue: * = null, newValue: * = null ): void {
			for( var id: String in _stored ) {
				var map: MapInformation = _stored[ id ];
				map.value = CLASS_MAPPINGS.getMapping( map.source, map.target );
			}
		}
	}
}
