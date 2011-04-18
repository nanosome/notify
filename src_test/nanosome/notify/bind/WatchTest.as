package nanosome.notify.bind {
	import flash.events.Event;
	import nanosome.notify.field.IFieldObserver;
	import nanosome.notify.sampleNS;
	import nanosome.util.EnterFrame;
	import nanosome.util.access.accessFor;
	import nanosome.util.access.qname;
	import org.mockito.integrations.flexunit3.MockitoTestCase;
	import org.mockito.integrations.inOrder;
	import org.mockito.integrations.mock;



	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public class WatchTest extends MockitoTestCase {
		
		private var _mock: IFieldObserver;
		private var _obj : Object;
		private var _call : Function;
		private var _dynamicInstance : DynamicClass;
		private var _arr1 : Array;
		private var _arr2 : Array;
		private var _arr3: Array;
		private var _nsSample: NamespaceSample;
		private var _watchedField : IWatchField;
		
		public function WatchTest() {
			super( [ IFieldObserver ] );
		}
		
		override public function setUp() : void {
			super.setUp();
			
			_mock = mock( IFieldObserver );
			
			_obj = {};
			_arr1 = [];
			_arr2 = [];
			_arr3 = [];
			_dynamicInstance = new DynamicClass( int.MAX_VALUE-3 );
			
			watch( _obj, "test" ).addObserver( _mock );
			watch( _obj, "obj.fun" ).addObserver( _mock );
			watch( _dynamicInstance, "bindable" ).addObserver( _mock );
			watch( _dynamicInstance, "observable" ).addObserver( _mock );
			watch( _dynamicInstance, "normal" ).addObserver( _mock );
			watch( _dynamicInstance, "bindable.1" ).addObserver( _mock );
			watch( _dynamicInstance, "observable.0" ).addObserver( _mock );
			
			_dynamicInstance.bindable = _arr1;
			_dynamicInstance.observable = _arr2;
			_dynamicInstance.normal = _arr3;
		}
		
		public function testSpecialBindingEvent(): void {
			_nsSample = new NamespaceSample();
			var nsField: IWatchField = watch( _nsSample, "eventVar" );
			nsField.addObserver( _mock );
			_nsSample.eventVar = "hi";
			inOrder().verify().that( _mock.onFieldChange( nsField, null, "hi" ) );
			nsField = watch( _nsSample, new QName( sampleNS, "bindable" ) );
			nsField.addObserver( _mock );
			_nsSample.sampleNS::bindable = "ho";
			inOrder().verify().that( _mock.onFieldChange( nsField, null, "ho" ) );
		}
		
		public function testNamespaceWatch(): void {
			_nsSample = new NamespaceSample();
			
			_watchedField = watch( _nsSample, path( qname("nanosome.notify.bind:sampleNs/test/$temp::test"), "length" ) );
			_watchedField.addObserver( _mock );
			assertEquals( "two times adressing the same field should return the same" +
						"watchField", _watchedField,
						watch( _nsSample, path( qname("nanosome.notify.bind:sampleNs/test/$temp::test"), "length" ) ) );
			
			_nsSample.sampleNS::test = "five";
			
			async( verifyNS1 );
			EnterFrame.add( callBack );
		}
		
		private function verifyNS1( e: Event ): void {
			inOrder().verify().that( _mock.onFieldChange( _watchedField, null, 4 ) );
			lastCall();
		}
		
		/*
		 * Event mapping to come in future version
		 * public function testEventPropertyWatch(): void {
			eventMap.forType( Sprite ).define( Event.CHANGE, "x", "y" );
			
			var sprite: Sprite = new Sprite();
			sprite.x = 30;
			sprite.y = 10;
			var xField: IWatchField = watch( sprite, "x" );
			var yField: IWatchField = watch( sprite, "y" );
			
			assertEquals( 30, xField.value );
			assertEquals( 10, yField.value );
			
			xField.listen( dummyListener );
			yField.listen( dummyListener );
			
			sprite.x = 20;
			sprite.y = 25;
			
			sprite.dispatchEvent( new Event( Event.CHANGE ) );
			
			// Now the change event came, nice
			assertEquals( 20, xField.value );
			assertEquals( 25, yField.value );
			
			eventMap.forType( Sprite ).define( Event.COMPLETE, "x", "y" );
			
			sprite.x = 15;
			sprite.y = 5;
			
			sprite.dispatchEvent( new Event( Event.CHANGE ) );
			
			// They should stay same because the events changed!
			assertEquals( 20, xField.value );
			assertEquals( 25, yField.value );
			
			sprite.dispatchEvent( new Event( Event.COMPLETE ) );
			
			// Now, with the proper event they should have changed
			assertEquals( 15, xField.value );
			assertEquals( 5, yField.value );
			
			eventMap.forType( Sprite ).define( null, "x", "y" );
			
			
		}
		 * 
		 */
		
		public function testPropertyWatch(): void {
			
			inOrder().verify().that( _mock.onFieldChange( watch( _dynamicInstance, "bindable" ), undefined, _arr1 ) );
			inOrder().verify().that( _mock.onFieldChange( watch( _dynamicInstance, "observable" ), undefined, _arr2 ) );
			
			_obj["test"] = true;
			_obj["obj"]  = { fun: "hi" };
			
			async( verifyCalled1 );
			EnterFrame.add( callBack );
		}
		
		public function testWatchNothing(): void {
			assertNotNull( watch( null, "something.anything" ) );
		}
		
		public function testWatchModification(): void {
			var obj: Object = {};
			watch( _dynamicInstance, "anything" ).value = obj;
			assertEquals( _dynamicInstance["anything"], obj );
			watch( _dynamicInstance, "anything.something" ).value = "Super!";
			assertEquals( "Super!", obj["something"] );
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
			inOrder().verify().that( _mock.onFieldChange( watch( _obj, "test" ), undefined, true ));
			inOrder().verify().that( _mock.onFieldChange( watch( _obj, "obj.fun" ), undefined, "hi") );
			inOrder().verify().that( _mock.onFieldChange( watch( _dynamicInstance, "normal" ), undefined, _arr3 ) );
			
			_dynamicInstance.bindable.push( "b" );
			_dynamicInstance.bindable.push( "c" );
			
			_dynamicInstance.observable.push( "1" );
			_dynamicInstance.observable.push( "2" );
			
			_obj["obj"]["fun"] = "a";
			async( verifyCalled2 );
		}
		
		private function verifyCalled2( e: Event ) : void {
			inOrder().verify().that( _mock.onFieldChange( watch( _dynamicInstance, "bindable.1" ), undefined, "c" ) );
			inOrder().verify().that( _mock.onFieldChange( watch( _dynamicInstance, "observable.0" ), undefined, "1" ) );
			inOrder().verify().that( _mock.onFieldChange( watch( _obj, "obj.fun" ), "hi", "a") );
			_obj["obj"] = null;
			
			_dynamicInstance.bindable = [ "f", "g" ];
			
			inOrder().verify().that( _mock.onFieldChange( watch( _dynamicInstance, "bindable.1" ), "c", "g" ) );
			
			async( verifyCalled3 );
		}
		
		private function verifyCalled3( e: Event ): void {
			inOrder().verify().that( _mock.onFieldChange( watch( _obj, "obj.fun" ), "a", undefined ) );
			lastCall();
		}
		
		private function lastCall() : void {
			_call = null;
			EnterFrame.remove( callBack );
		}
		
		override public function tearDown() : void {
			super.tearDown();
			lastCall();
			watch( _obj, "test" ).removeObserver( _mock );
			watch( _obj, "obj.fun" ).removeObserver( _mock );
			watch( _dynamicInstance, "bindable").removeObserver( _mock );
			watch( _dynamicInstance, "observable").removeObserver( _mock );
			watch( _dynamicInstance, "normal").removeObserver( _mock );
			watch( _dynamicInstance, "bindable.1").removeObserver( _mock );
			watch( _dynamicInstance, "observable.0").removeObserver( _mock );
			_mock = null;
		}
		
		
	}
}