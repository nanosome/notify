package nanosome.notify.connect.impl {
	import nanosome.util.ChangedPropertyNode;
	import nanosome.util.pool.WeakDictionary;

	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	internal final class WeakDelayConnector extends AbstractDelayConnector {
		
		private const _weakDictionary: WeakDictionary = new WeakDictionary();
		
		public function WeakDelayConnector() {
			super();
		}
		
		override public function init( objectA: Object, objectB: Object, mapping: MapInformation ): IConnector {
			super.init( objectA, objectB, mapping );
			_weakDictionary[ objectA ] = true;
			_weakDictionary[ objectB ] = true;
			_objectA = null;
			_objectB = null;
			return this;
		}
		
		override public function onPropertyChange( observable: *, propertyName: QName, oldValue: *, newValue: * ): void {
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
				super.onPropertyChange( observable, propertyName, oldValue, newValue );
				_objectA = null;
				_objectB = null;
			} else {
				dispose();
			}
		}
		
		override public function onManyPropertiesChanged( observable : *, changes: ChangedPropertyNode ): void {
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
				super.onManyPropertiesChanged( observable, changes );
				_objectA = null;
				_objectB = null;
			} else {
				dispose();
			}
		}
		
		override protected function applyChanges(): void {
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
				super.applyChanges();
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
