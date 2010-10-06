package nanosome.notify.bind {

	import nanosome.notify.observe.Observable;

	public dynamic class DynamicClass extends Observable {
		
		private var _uid: uint;
		
		public function DynamicClass( id: uint ) {
			_uid = id;
		}
		
		override public function get uid() : uint {
			return _uid;
		}
		
		public var normal: Array;
		
		public var internalClass: InternalClass;
		
		internal var internalVariable: Array;
		
		[Bindable]
		public var bindable: Array;
		
		private var _observable: Array;
		
		[Observable]
		public function get observable(): Array {
			return _observable;
		}
		
		public function set observable( observable: Array ): void {
			if( _observable != observable ) notifyPropertyChange( "observable", _observable, _observable = observable );
		}
		
		public var wasLocked: Boolean;
		public var wasUnlocked: Boolean;
		
		override public function set locked(locked : Boolean) : void {
			if( locked != this.locked ) {
				if( locked ) {
					wasLocked = true;
					wasUnlocked = false;
				} else if( wasLocked ) {
					wasUnlocked = true;
				}
			}
			super.locked = locked;
		}
	}
}

class InternalClass {
}