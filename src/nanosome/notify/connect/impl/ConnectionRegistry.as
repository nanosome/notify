package nanosome.notify.connect.impl {
	import nanosome.util.pool.poolFor;
	import nanosome.util.access.accessFor;
	import nanosome.util.pool.WeakDictionary;
	import nanosome.util.pool.poolInstance;
	
	/**
	 * @author mh
	 */
	public class ConnectionRegistry {
		
		private const _connections: WeakDictionary = new WeakDictionary();
		private const _mapStorage: MapInformationStorage = new MapInformationStorage();
		
		public function ConnectionRegistry() {
			super();
		}
		
		public function connect( source: *, target: *, weak: Boolean = false,
									onEnterFrame: Boolean = true ): Boolean {
			// only connect objects!
			if( source is Object && target is Object ) {
				
				var sourceConnections: WeakDictionary = _connections[ source ]
							|| ( _connections[ source ] = WeakDictionary.POOL.getOrCreate() );
				var targetConnections: WeakDictionary = _connections[ target ]
							|| ( _connections[ target ] = WeakDictionary.POOL.getOrCreate() );
				
				var connector: IConnector = sourceConnections[ target ];
				
				if( connector && ( connector.weak != weak || connector.onEnterFrame != onEnterFrame ) ) {
					returnConnector( connector );
					connector = null;
				}
				
				if( !connector ) {
					
					var clazz: Class = (
						weak
						? ( onEnterFrame ? WeakDelayConnector : WeakConnector )
						: ( onEnterFrame ? DelayConnector : Connector )
					);
					
					connector = IConnector( poolInstance( clazz ) );
					connector.init(
						source, target,
						_mapStorage.getMap( accessFor( source ), accessFor( target ) )
					);
					
					targetConnections[ source ]
							= sourceConnections[ target ]
							= connector;
					return true;
				} else {
					return false;
				}
			} else {
				return false;
			}
		}
		
		public function disconnect( source: *, target: * ): Boolean {
			var connections: WeakDictionary = _connections[ source ];
			if( connections ) {
				
				var connector: IConnector = connections[ target ];
				if( connector ) {
					returnConnector( connector );
					delete connections[target];
					for( var found: * in connections ) {
						break;
					}
					if( !found ) {
						delete _connections[ source ];
						found = undefined;
					}
					
					connections = _connections[ target ];
					if( connections ) {
						delete connections[ source ];
						for( found in connections ) {
							break;
						}
						if( !found ) {
							delete _connections[ target ];
						}
					}
					
					return true;
				} else {
					return false;
				}
			} else {
				return false;
			}
			
		}
		
		private function returnConnector( connector: IConnector ): void {
			var clazz: Class;
			if( connector is Connector ) {
				clazz = Connector;
			} else if( connector is WeakConnector ) {
				clazz = WeakConnector;
			} else if( connector is DelayConnector ) {
				clazz = WeakConnector;
			} else if( connector is WeakDelayConnector ) {
				clazz = WeakConnector;
			}
			poolFor( clazz ).returnInstance( connector );
		}
		
		public function disconnectEntirely( object: * ): Boolean {
			var connections: WeakDictionary = _connections[ object ];
			if( connections ) {
				for( var target: * in connections ) {
					disconnect( object, target );
				}
				return true;
			} else {
				return false;
			}
		}
	}
}
