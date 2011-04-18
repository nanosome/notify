package nanosome.notify.bind {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import nanosome.notify.sampleNS;
	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public class NamespaceSample extends EventDispatcher {
		
		sampleNS var test: String;
		
		[Bindable]
		sampleNS var bindable: String;
		
		private var _str: String;
		
		[Bindable(event="blah")]
		public function set eventVar( str: String ): void {
			if( str != _str ) {
				_str = str;
				dispatchEvent( new Event( "blah" ) );
			}
		}
		
		public function get eventVar(): String {
			return _str;
		}
	}
}
