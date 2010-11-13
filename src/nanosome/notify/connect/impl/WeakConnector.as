package nanosome.notify.connect.impl {
	import nanosome.util.pool.WeakDictionary;

	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	internal final class WeakConnector extends AbstractDynamicConnector {
		
		private const _weakDictionary: WeakDictionary = new WeakDictionary();
		
		public function WeakConnector() {
			super();
		}
		
		override public function init( objectA: Object, objectB: Object, map: MapInformation ): IConnector {
			super.init( objectA, objectB, map );
			_weakDictionary[ objectA ] = true;
			_weakDictionary[ objectB ] = true;
			_objectA = null;
			_objectB = null;
			return this;
		}
		
		override protected function compareCacheWithReality() : void {
			var first: Boolean = true;
			for( var object: * in _weakDictionary ) {
				if( first ) {
					_objectA = object;
					first = false;
				} else {
					_objectB = object;
				}
			}
			if( _objectB ) {
				compareCacheWithReality();
				_objectA = null;
				_objectB = null;
			} else {
				dispose();
			}
		}
		
		override public function get weak() : Boolean {
			return true;
		}
		
		override public function dispose() : void {
			var first: Boolean = true;
			for( var object: * in _weakDictionary ) {
				if( first ) {
					_objectA = object;
					first = false;
				} else {
					_objectB = object;
				}
			}
			super.dispose();
			_weakDictionary.dispose();
		}
	}
}
