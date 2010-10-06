package nanosome.notify.observe {
	
	import nanosome.util.ChangedPropertyNode;
	
	import nanosome.util.UID;
	import nanosome.util.pool.InstancePool;
	import nanosome.util.pools;

	import org.mockito.MockitoTestCase;

	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public class PropertyBroadcasterTest extends MockitoTestCase implements IPropertyObserver {
		
		private var _broadcaster: PropertyBroadcaster;
		private var _changeNodePool: InstancePool = pools.getOrCreate( ChangedPropertyNode);
		private var _uid : uint = UID.next();
		private var _lastManyProperties : Array;

		public function PropertyBroadcasterTest() {
			super( [ IPropertyObserver ] );
		}
		
		override public function setUp(): void {
			_broadcaster = new PropertyBroadcaster();
		}
		
		public function testDispose(): void {
			_broadcaster.target = this;
			_broadcaster.dispose();
			assertNull( _broadcaster.target );
			_broadcaster.locked = true;
			_broadcaster.dispose();
			assertFalse( _broadcaster.locked );
		}
		
		public function testNormalFunctionality(): void {
			
			var observer: IPropertyObserver = mock( IPropertyObserver );
			
			_broadcaster.target = this;
			_broadcaster.add( observer );
			_broadcaster.notifyPropertyChange( "bunny", 10, 12 );
			_broadcaster.notifyPropertyChange( "bucks", "a", "b" );
			
			var first: ChangedPropertyNode = _changeNodePool.getOrCreate();
			first.name = "bucks";
			first.newValue = 12;
			first.oldValue = 10;
			
			var second: ChangedPropertyNode = _changeNodePool.getOrCreate();
			second.name = "bunny";
			second.newValue = "b";
			second.oldValue = "a";
			second.addTo( first );
			
			// This is a little bit of an advanced test that asserts that in
			// locked mode no property-change notification will be executed
			// and it asserts as well that changes will be merged and nodes will
			// be removed if not triggered
			_broadcaster.locked = true;
			assertTrue( _broadcaster.locked );
			_broadcaster.notifyPropertyChange( "bunny", "b", "c" );
			_broadcaster.notifyPropertyChange( "bucks", 1, 2 );
			_broadcaster.notifyManyPropertiesChanged( first );
			_broadcaster.locked = false;
			assertFalse( _broadcaster.locked );
			
			_broadcaster.add( this );
			_broadcaster.notifyManyPropertiesChanged( first );
			
			// Asserts that the notification for many properties puts out the
			// list in exactly matching order with all values
			assertObjectEquals( [ {
					name: "bucks",
					newValue: 12,
					oldValue: 10
				}, {
					name: "bunny",
					newValue: "b",
					oldValue: "a"
				}], _lastManyProperties);
			
			
			_broadcaster.remove( observer );
			_broadcaster.remove( this );
			
			inOrder().verify().that( observer.onPropertyChange( this, "bunny", 10, 12 ) );
			inOrder().verify().that( observer.onPropertyChange( this, "bucks", "a", "b" ) );
			inOrder().verify().that( observer.onPropertyChange( this, "bucks", 1, 12 ) );
			verify( times(3) ).that( observer.onPropertyChange( any(), any(), any(), any() ) );
			verify( times(1) ).that( observer.onManyPropertiesChanged( any(), any() ));
		}
		
		public function onPropertyChange( observable: *, propertyName: String, oldValue: *, newValue: * ): void {
		}
		
		/**
		 * Helper method to easier provide a testcase for the case if many properties change
		 */
		public function onManyPropertiesChanged( observable: *, changes: ChangedPropertyNode ): void {
			var nodes: Array = [];
			var current: ChangedPropertyNode = changes;
			while( current ) {
				nodes.push( {
					name: current.name,
					oldValue: current.oldValue,
					newValue: current.newValue
				} );
				current = current.next;
			}
			_lastManyProperties = nodes;
		}
		
		public function get uid(): uint {
			return _uid;
		}
	}
}
