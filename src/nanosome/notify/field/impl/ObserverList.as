// @license@ 
package nanosome.notify.field.impl {
	
	import nanosome.notify.field.IField;
	import nanosome.notify.field.IFieldObserver;
	import nanosome.util.list.List;
	import nanosome.util.list.ListNode;
	import nanosome.util.pool.poolFor;
	
	/**
	 * <code>ObserverList</code> is a concrete list that extends the <code>List</code>
	 * template.
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @version 1.0
	 */
	public class ObserverList extends List {
		
		// Holds the first node in the list
		private var _first: ObserverListNode;
		
		// Holds the last node in the list
		private var _next: ObserverListNode;
		
		public function ObserverList() {
			super( poolFor( ObserverListNode ) );
		}
		
		/**
		 * Propagates the change of a field to its observers.
		 * 
		 * @param mo <code>IField</code> about which the notification should be done
		 * @param oldValue Old value of the field.
		 * @param newValue New value of the field.
		 */
		public final function notifyPropertyChange( mo: IField, oldValue: *, newValue: * ): void {
			var current: ObserverListNode = _first;
			var observer: IFieldObserver;
			
			var first: Boolean = _isIterating ? subIterate() : _isIterating = true;
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
			first ? stopIteration() : stopSubIteration();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function get first(): ListNode {
			return _first;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function set first(node : ListNode) : void {
			_first = ObserverListNode( node );
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function get next() : ListNode {
			return _next;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function set next( node: ListNode ) : void {
			_next = ObserverListNode( node );
		}
	}
}