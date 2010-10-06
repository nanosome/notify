// @license@
package nanosome.notify.field.impl {
	import nanosome.notify.field.IFieldObserver;
	import nanosome.util.list.ListNode;

	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @version 1.0
	 */
	public class ObserverListNode extends ListNode {
		
		public var strongObserver: IFieldObserver;
		public var nextObserver: ObserverListNode;
		
		override public function set strong( content: * ): void {
			strongObserver = IFieldObserver( content );
		}
		
		override public function get strong(): * {
			return strongObserver;
		}
		
		override public function set next( node : ListNode ): void
		{
			super.next = node;
			nextObserver = ObserverListNode( node );
		}
	}
}
