package nanosome.notify.connect {
	import nanosome.notify.sampleNS;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	
	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public dynamic class Dynamic3 extends EventDispatcher {
		
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
