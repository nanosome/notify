package nanosome.notify.connect {
	import nanosome.notify.observe.Observable;
	import nanosome.util.access.qname;
	/**
 * @author Martin Heidegger mh@leichtgewicht.at
 */
	public dynamic class Dynamic1 extends Observable {
		
		public var a: String = "1";
		
		// Differenty named than in Dyn2
		public var b: String = "2";
		
		// Differently typed than in Dyn2
		public var c: int = 3;
		
		public function set d( value: * ): void {
			throw new Error( "unsetable" );
		}
		
		public function get d(): * {
			return "a";
		}
		
		public var g: String = "a";
		
		[Bindable]
		public var h: String = "15";
		
		private var _i: int = 16;
		
		[Observable]
		public function set i( i: int ): void {
			if( i != _i ) notifyPropertyChange( qname( "i" ), _i, _i=i );
		}
		
		public function get i(): int {
			return _i;
		}
	}
}
