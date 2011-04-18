package nanosome.notify.connect {
	
	
	import nanosome.notify.bind.map.CLASS_MAPPINGS;
	import flexunit.framework.TestCase;

	import nanosome.util.EnterFrame;

	import flash.events.Event;

	/**
 * @author Martin Heidegger mh@leichtgewicht.at
 */
	public class DynamicConnectionTest extends TestCase {
		
		private var _call: Function;
		private var _objB: Object;
		private var _objA: Object;
		private var _dictA: Dynamic1;
		private var _dictB: Dynamic2;
		
		private function async( fnc: Function) : void {
			_call = addAsync( fnc, 1000 );
		}
		
		private function callBack() : void {
			_call( new Event( Event.COMPLETE ) );
		}
		
		private function lastCall() : void {
			_call = null;
			EnterFrame.remove( callBack );
		}
		
		public function testRegularConnect(): void {
			_objA = {
				a: "x",
				b: "y"
			};
			
			_objB = {
				a: "a",
				b: "b",
				c: "x"
			};
			
			assertTrue( connect( _objA, _objB ) );
			assertFalse( connect( _objA, _objB ) );
			
			assertEquals( "x", _objA["a"] );
			assertEquals( "y", _objA["b"] );
			assertEquals( "x", _objB["a"] );
			assertEquals( "y", _objB["b"] );
			assertFalse( _objB.hasOwnProperty( "c" ) );
			
			_objA["a"] = "c";
			delete _objA["b"];
			
			assertEquals( "x", _objB["a"] );
			assertEquals( "y", _objB["b"] );
			assertFalse( _objA.hasOwnProperty( "b" ) );
			
			async( verifyDynamicSync );
			EnterFrame.add( callBack );
		}
		
		private function verifyDynamicSync( e: Event ): void {
			assertEquals( "c", _objA["a"] );
			assertEquals( "c", _objB["a"] );
			assertFalse( _objB.hasOwnProperty( "b" ) );
			
			_objA["c"] = 1;
			_objB["c"] = 3;
			
			async( verifyCrossChanges );
		}
			
		private function verifyCrossChanges( e: Event ): void {
			assertStrictlyEquals( 1, _objA["c"] );
			assertStrictlyEquals( 1, _objB["c"] );
			
			assertTrue( disconnect( _objA, _objB ) );
			assertFalse( disconnect( _objA, _objB ) );
			
			_objA[ "a" ] = 3;
			
			async( verifyDisconnected );
		}
		
		private function verifyDisconnected( e: Event ) : void {
			assertEquals( "c", _objB["a"] );
			assertEquals( 3, _objA["a"] );
			
			assertFalse( disconnect( _objA, _objB ) );
			
			assertTrue( connect( _objA, _objB ) );
			// This will not make a difference, but lets see if its really changing
			// something
			assertTrue( connect( _objA, _objB, false, true ) );
			assertTrue( connect( _objA, _objB, false, false ) );
			assertTrue( disconnect( _objA, _objB ) );
			assertFalse( disconnect( _objA, _objB ) );
			
			lastCall();
		}
		
		public function testMapping(): void {
			_dictA = new Dynamic1();
			_dictA["e"] = 7;
			_dictB = new Dynamic2();
			_dictB["e"] = 8;
			_dictB["f"] = 9;
			
			CLASS_MAPPINGS.addMapping( Dynamic1, Dynamic2, {
				a: "a",
				b: "x",
				c: "c",
				d: "d",
				g: "g",
				h: "y",
				i: "z"
			} );
			
			assertTrue( connect( _dictA, _dictB ) );
			
			assertEquals( "1", _dictA.a );
			assertEquals( "2", _dictA.b );
			assertStrictlyEquals( 3, _dictA.c );
			assertEquals( 7, _dictA["e"] );
			assertFalse( _dictA.hasOwnProperty("f") );
			assertStrictlyEquals( "0", _dictA.g );
			assertEquals( "15", _dictA.h );
			assertEquals( 16, _dictA.i );
			
			assertEquals( "1", _dictB.a );
			assertEquals( "2", _dictB.x );
			assertStrictlyEquals( "3", _dictB.c );
			assertEquals( 7, _dictA["e"] );
			
			assertFalse( _dictB.hasOwnProperty("f") );
			assertStrictlyEquals( 0, _dictB.g );
			assertEquals( 15, _dictB.y );
			assertEquals( "16", _dictB.z );
			
			
			_dictA.g = "x";
			_dictB.g = 3;
			
			assertStrictlyEquals( "x", _dictA.g );
			assertStrictlyEquals( 3, _dictB.g );
			
			_dictA.h = "17";
			
			assertEquals( 17, _dictB.y );
			assertEquals( "17", _dictA.h );
			
			async( verifyMappingChange );
			EnterFrame.add( callBack );
		}
		
		private function verifyMappingChange( e: Event ): void {
			
			assertStrictlyEquals( "0", _dictA.g );
			assertStrictlyEquals( 0, _dictB.g );
			
			disconnect( _dictA, _dictB );
			
			lastCall();
		}
	}
}