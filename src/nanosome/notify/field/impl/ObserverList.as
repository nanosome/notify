// @license@
package nanosome.notify.field.impl {
	import nanosome.notify.field.IFieldObserver;
	import nanosome.notify.field.IField;
	import nanosome.util.list.List;
	import nanosome.util.list.ListNode;
	import nanosome.util.pools;
	
	/**
	 * @author mh
	 */
	public class ObserverList extends List {
		
		private var _first: ObserverListNode;
		private var _next: ObserverListNode;
		public function ObserverList() {
			super( pools.getOrCreate( ObserverListNode ) );
		}
		
		override protected function get first(): ListNode {
			return _first;
		}
		
		override protected function set first(node : ListNode) : void {
			_first = ObserverListNode( node );
		}
		
		override protected function get next() : ListNode {
			return _next;
		}
		
		override protected function set next( node: ListNode ) : void {
			_next = ObserverListNode( node );
		}
		
		public function notifyPropertyChange( mo: IField, oldValue: *, newValue: * ): void {
			var current: ObserverListNode = _first;
			var observer: IFieldObserver;
			
			startIterate();
			while( current ) {
				_next = current.nextObserver;
				observer = current.strongObserver;
				if( observer ) {
					observer.onFieldChange( mo, oldValue, newValue );
				} else {
					observer = current.weak;
					if( observer ) {
						observer.onFieldChange( mo, oldValue, newValue );
					} else {
						removeNode( current );
					}
				}
				current = _next;
			}
			stopIterate();
		}
	}
}