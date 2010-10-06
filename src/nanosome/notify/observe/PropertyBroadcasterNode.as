// @license@
package nanosome.notify.observe {
	
	
	import nanosome.util.list.ListNode;
	
	/**
	 * <code>PropertyBroadcasterNode</code> is a implementation for internal use
	 * that provides a easy way to implement broadcasting for easy implementations
	 * of the <code>IPropertyObservable</code> interface.
	 * 
	 * <p>This instance is internal in order to be able to make it final (performance)
	 * and to have the properties as internal variables.</p>
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @version 1.0
	 * @see IPropertyObservable
	 */
	internal final class PropertyBroadcasterNode extends ListNode {
		
		/**
		 * Observer matching to this node.
		 */
		internal var _strong: IPropertyObserver;
		
		/**
		 * Next node to be executed
		 */
		internal var _next: PropertyBroadcasterNode;
		
		/**
		 * @inheritDoc
		 */
		override public function set next( node: ListNode ): void {
			super.next = node;
			_next = PropertyBroadcasterNode( node );
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set strong( content: * ): void {
			_strong = IPropertyObserver( content );
		}
		
		override public function get strong(): * {
			return _strong;
		}
	}
}
