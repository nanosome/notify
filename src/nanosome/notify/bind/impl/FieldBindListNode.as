// @license@

package nanosome.notify.bind.impl {
	import nanosome.notify.field.IField;
	import nanosome.util.IUID;
	import nanosome.util.list.UIDListNode;
	
	
	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public class FieldBindListNode extends UIDListNode {
		
		// TODO: NOTE weak entries are by now not used!
		
		public var field: IField;
		public var nextNode: FieldBindListNode;
		
		override public function set strong( content: IUID ): void {
			field = IField( content );
		}
		
		override public function get strong(): IUID {
			return field;
		}

		override public function set next(node : UIDListNode) : void {
			super.next = node;
			nextNode = FieldBindListNode( node );
		}
	}
}
