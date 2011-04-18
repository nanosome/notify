package nanosome.notify.connect {
	import flexunit.framework.TestCase;

	import nanosome.notify.bind.map.CLASS_MAPPINGS;
	import nanosome.notify.sampleNS;

	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public class StaticConnectionTest extends TestCase {
		
		private var _1: Static1;
		private var _2: Static2;
		private var _3: Static3;
		
		public function StaticConnectionTest() {
			super();
		}
		
		public function testSpecialEventConnect(): void {
			_3 = new Static3();
			_3.sampleNS::x = "20";
			_2 = new Static2();
			
			CLASS_MAPPINGS.addMapping( Static3, Static2, {
				"custom": "a",
				"nanosome.notify.bind:sampleNs/test/$temp::x": "b"
			});
			
			connect( _3, _2 );
			
			assertEquals( "namespaces shouldnt hinder the connection process", "20", _2.b );
			
			_3.custom = "10";
			
			assertEquals( "The custom event sent by custom= should have trigged " +
						  "the update of _dictB.a", 10, _2.a );
		}
		
		public function testStatic(): void {
			
			CLASS_MAPPINGS.addMapping( Static1, Static2, {
				c: "a",
				x: "b"
			} );
			
			_1 = new Static1();
			_2 = new Static2();
			
			connect( _1, _2 );
			
			assertEquals( "3", _1.c );
			assertEquals( 7, _1.x );
			assertEquals( 3, _2.a );
			assertEquals( "7", _2.b );
		}
	}
}
