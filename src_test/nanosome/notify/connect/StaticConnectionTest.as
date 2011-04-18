package nanosome.notify.connect {
	import flexunit.framework.TestCase;

	import nanosome.notify.bind.map.CLASS_MAPPINGS;

	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public class StaticConnectionTest extends TestCase {
		
		private var _1: Static1;
		private var _2: Static2;
		
		public function StaticConnectionTest() {
			super();
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
