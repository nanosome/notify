package nanosome.notify.connect {
	/**
 * @author Martin Heidegger mh@leichtgewicht.at
 */
	public dynamic class Dynamic2 {
		public var a: String = "4";
		public var x: String = "5";
		public var c: String = "6";
		
		public function set d( value: * ): void {}
		
		public function get d(): * {
			throw new Error( "ungetable" );
		}
		
		public var g: int = 11;
		
		public var y: int = 12;
		
		public var z: String = "13";
	}
}
