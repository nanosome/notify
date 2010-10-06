// @license@

package nanosome.notify.bind.impl {
	import nanosome.util.IUID;
	import nanosome.notify.field.IField;
	import nanosome.util.list.UIDList;
	import nanosome.util.list.UIDListNode;
	import nanosome.util.pools;
	

	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public class FieldBindList extends UIDList {
		
		private var _first: FieldBindListNode;
		private var _next: FieldBindListNode;
		private var _unchangable: IField;
		private var _value : *;
		private var _master: IField;

		public function FieldBindList() {
			super( pools.getOrCreate( FieldBindListNode ) );
		}
		
		override public function add( content: IUID, weak: Boolean = false ): Boolean {
			var field: IField = IField( content );
			if( !field.isChangeable && _unchangable ) {
				throw new Error( "Trying to bind fields where at least two fields"
										+ " are unchangable: '" + _unchangable + "' and"
										+ " '" + field + "'; cross-lock");
			}
			var added: Boolean = super.add( content, weak );
			if( !field.isChangeable ) {
				_unchangable = field;
				// Apply the content of this MO to all others
				changeValue( field );
			} else if( _first.field == field ) {
				_value = field.value;
			} else {
				field.value = _value;
			}
			return added;
		}
		
		override public function remove( value: IUID ): Boolean {
			var removed: Boolean = super.remove( value );
			if( value == _unchangable ) {
				_unchangable = null;
			}
			if( value == _master ) {
				_master = null;
			}
			return removed;
		}
		
		public function get firstNode(): FieldBindListNode {
			return FieldBindListNode( _first );
		}
		
		override protected function get first(): UIDListNode {
			return _first;
		}
		
		override protected function set first( node: UIDListNode ): void {
			_first = FieldBindListNode( node );
		}
		
		override protected function get next(): UIDListNode {
			return _next;
		}
		
		override protected function set next( node: UIDListNode ): void {
			_next = FieldBindListNode( node );
		}
		
		override public function dispose(): void {
			super.dispose();
			_unchangable = null;
			_first = null;
			_next = null;
			_value = null;
		}
		
		public function changeValue( field: IField ): void {
			if( field != _master && _unchangable == field && field.isChangeable ) {
				_unchangable = null;
			} else if( _unchangable != field && !field.isChangeable ) {
				// TODO: Think of a event handling instead of this exception,
				// it might cause problems in production
				if( _master && field != _master ) {
					throw new Error( "Field '" + field + "' became unchangable but"
									+ " it was already bound as slave to the"
									+ " field '" + _master + "'; cross-lock" );
				}
				if( _unchangable ) {
					throw new Error( "Field '" + field + "' became unchangable but"
									+ " it was already bound to another unchangable"
									+ " field '" + _unchangable + "'; cross-lock" );
				}
				_unchangable = field;
			}
			if( _unchangable && _unchangable != field ) {
				// Revert changing of value since it would conflict with the
				// one unchangable one.
				field.value = _unchangable.value;
			} else {
				var current: FieldBindListNode = _first;
				var value: * = _value = field.value;
				while( current ) {
					_next = current.nextNode;
					if( field != current.field ) {
						current.field.value = value;
					}
					current = _next;
				}
			}
		}
		
		public function set master( master: IField ): void {
			if( master != _master ) {
				// In case the former master has been registered als unchangable
				if( _unchangable && !_unchangable.isChangeable ) {
					throw new Error( "Trying to apply uni-directional binding while"
										+ " it was already bound to a unchangable field '"
										+ _unchangable + "'; cross-lock" );
				}
				_master = master;
				_unchangable = master;
				changeValue( _master );
			}
		}
		
		public function get unchangable(): IField {
			return _unchangable;
		}
		
		public function get master(): IField {
			return _master;
		}
	}
}
