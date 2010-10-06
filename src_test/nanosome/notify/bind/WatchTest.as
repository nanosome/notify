package nanosome.notify.bind {
	import nanosome.notify.observe.IPropertyObserver;
	
	import nanosome.util.EnterFrame;

	import org.mockito.integrations.flexunit3.MockitoTestCase;
	import org.mockito.integrations.inOrder;
	import org.mockito.integrations.mock;

	import flash.events.Event;

	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public class WatchTest extends MockitoTestCase {
		
		private var _mock: IPropertyObserver;
		private var _obj : Object;
		private var _call : Function;
		private var _dynamicInstance : DynamicClass;
		private var _arr1 : Array;
		private var _arr2 : Array;
		private var _arr3 : Array;
		
		public function WatchTest() {
			super( [ IPropertyObserver ] );
		}
		
		override public function setUp() : void {
			super.setUp();
			
			_mock = mock( IPropertyObserver );
			
			_obj = {};
			_arr1 = [];
			_arr2 = [];
			_arr3 = [];
			_dynamicInstance = new DynamicClass( int.MAX_VALUE-3 );
			
			watch( _obj, "test" ).addPropertyObserver( _mock );
			watch( _obj, "obj.fun" ).addPropertyObserver( _mock );
			watch( _dynamicInstance, "bindable").addPropertyObserver( _mock );
			watch( _dynamicInstance, "observable").addPropertyObserver( _mock );
			watch( _dynamicInstance, "normal").addPropertyObserver( _mock );
			watch( _dynamicInstance, "bindable.1").addPropertyObserver( _mock );
			watch( _dynamicInstance, "observable.0").addPropertyObserver( _mock );
			
			_dynamicInstance.bindable = _arr1;
			_dynamicInstance.observable = _arr2;
			_dynamicInstance.normal = _arr3;
		}
		
		public function testPropertyWatch(): void {
			
			inOrder().verify().that( _mock.onPropertyChange( _dynamicInstance, "bindable", undefined, _arr1 ) );
			inOrder().verify().that( _mock.onPropertyChange( _dynamicInstance, "observable", undefined, _arr2 ) );
			
			_obj.test = true;
			_obj.obj = { fun: "hi" };
			
			async( verifyCalled1 );
			EnterFrame.add( callBack );
		}
		
		public function testWatchNothing(): void {
			assertNotNull( watch( null, "something.anything" ) );
		}
		
		public function testWatchModification(): void {
			var obj: Object = {};
			watch( _dynamicInstance, "anything" ).value = obj;
			assertEquals( _dynamicInstance.anything, obj );
			watch( _dynamicInstance, "anything.something" ).value = "Super!";
			assertEquals( obj.something, "Super!" );
			var exceptThrown: Boolean = false;
			watch( _dynamicInstance, "nothing.something" ).value = "What?";
			assertFalse( watch( _dynamicInstance, "nothing.something" ).setValue( "What?" ) );
		}
		
		private function async( fnc: Function) : void {
			_call = addAsync( fnc, 1000 );
		}

		private function callBack() : void {
			_call( new Event( Event.COMPLETE ) );
		}
		
		private function verifyCalled1( event: Event ) : void {
			inOrder().verify().that( _mock.onPropertyChange( _obj, "test", undefined, true ));
			inOrder().verify().that( _mock.onPropertyChange( _obj, "obj.fun", undefined, "hi") );
			inOrder().verify().that( _mock.onPropertyChange( _dynamicInstance, "normal", undefined, _arr3 ) );
			
			_dynamicInstance.bindable.push( "b" );
			_dynamicInstance.bindable.push( "c" );
			
			_dynamicInstance.observable.push( "1" );
			_dynamicInstance.observable.push( "2" );
			
			_obj.obj.fun = "a";
			async( verifyCalled2 );
		}
		
		private function verifyCalled2( e: Event ) : void {
			inOrder().verify().that( _mock.onPropertyChange( _dynamicInstance, "bindable.1", undefined, "c" ) );
			inOrder().verify().that( _mock.onPropertyChange( _dynamicInstance, "observable.0", undefined, "1" ) );
			inOrder().verify().that( _mock.onPropertyChange( _obj, "obj.fun", "hi", "a") );
			_obj.obj = null;
			
			_dynamicInstance.bindable = [ "f", "g" ];
			
			inOrder().verify().that( _mock.onPropertyChange( _dynamicInstance, "bindable.1", "c", "g" ) );
			
			async( verifyCalled3 );
		}
		
		private function verifyCalled3( e: Event ): void {
			inOrder().verify().that( _mock.onPropertyChange( _obj, "obj.fun", "a", undefined ) );
			lastCall();
		}
		
		private function lastCall() : void {
			_call = null;
			EnterFrame.remove( callBack );
		}
		
		override public function tearDown() : void {
			super.tearDown();
			lastCall();
			watch( _obj, "test" ).removePropertyObserver( _mock );
			watch( _obj, "obj.fun" ).removePropertyObserver( _mock );
			watch( _dynamicInstance, "bindable").removePropertyObserver( _mock );
			watch( _dynamicInstance, "observable").removePropertyObserver( _mock );
			watch( _dynamicInstance, "normal").removePropertyObserver( _mock );
			watch( _dynamicInstance, "bindable.1").removePropertyObserver( _mock );
			watch( _dynamicInstance, "observable.0").removePropertyObserver( _mock );
			_mock = null;
		}
	}
}