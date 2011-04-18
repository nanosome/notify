package nanosome.notify.connect {
	import nanosome.notify.sampleNS;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public class Static3 extends EventDispatcher {
		
		private var _prop: String;
		
		[Bindable("custom")]
		public function set custom( prop: String ): void {
			if( prop != _prop ) {
				_prop = prop;
				dispatchEvent( new Event("custom") );
			}
		}
		
		public function get custom(): String {
			return _prop;
		}
		
		sampleNS var x: String = "c";
	}
}
