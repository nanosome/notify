// @license@ 
package nanosome.notify.observe {
	
	import nanosome.util.ChangedPropertyNode;
	import nanosome.util.ILockable;
	import nanosome.util.list.List;
	import nanosome.util.list.ListNode;
	import nanosome.util.pool.IInstancePool;
	import nanosome.util.pool.poolFor;
	
	/**
	 * <code>PropertyBroadcaster</code> is a <strong>util</strong> to implement
	 * a <code>IPropertyObservable</code>.
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @version 1.0
	 * @see IPropertyObservable
	 */
	public final class PropertyBroadcaster extends List implements ILockable, IPropertyObservable {
		
		/**
		 * Pool of nodes to be used for nodes that changed.
		 */
		private static const _changeNodePool: IInstancePool =
				poolFor( ChangedPropertyNode );
		
		/**
		 * Target to which this broadcaster belongs to.
		 * 
		 * <p>This variable can be made public since this is a <strong>final</strong>
		 * class and its just a convenience feature. A getter/setter would be
		 * unnecessary overhead.</p>
		 */
		private var _target: *;
		
		// First node in the list
		private var _first: PropertyBroadcasterNode;
		
		// Next node to be executed, while broadcasting
		private var _next: PropertyBroadcasterNode;
		
		// First property that has been changed
		private var _firstChangedNode: ChangedPropertyNode;
		
		// Last property that has been changed
		private var _lastChangedNode: ChangedPropertyNode;
		
		// Map of properties that have been changed
		private var _changeMap: Object /* String -> ChangedPropertyNode */;
		
		private var _locked: Boolean = false;
		
		/**
		 * Creates a new instance of the <code>PropertyBroadcaster</code>
		 * 
		 * @param target Target to be used on initialization of the instance
		 */
		public function PropertyBroadcaster( target: * = null ) {
			super( poolFor( PropertyBroadcasterNode ) );
			this.target = target;
		}
		
		/**
		 * Remove all locks &amp; the target and clears the list.
		 */
		override public function dispose(): void {
			_target = null;
			if( _firstChangedNode ) {
				clearChangeNodes();
			}
			_locked = false;
			super.dispose();
		}
		
		public function set target( target: * ): void {
			_target = target;
		}
		
		public function get target(): * {
			return _target;
		}
		
		/**
		 * Triggers many propertychanges on the object
		 * 
		 * @param changes All changes to notify.
		 */
		public function notifyManyPropertiesChanged( changes: ChangedPropertyNode ): void {
			// Without changes supplied, fail gracefully
			if( changes ) {
				if( _locked ) {
					// If locked add the current changes to the list of changes.
					var currentChange: ChangedPropertyNode = changes;
					while( currentChange ) {
						addToChangeMap( currentChange.name, currentChange.oldValue, currentChange.newValue );
						currentChange = currentChange.next;
					}
				} else if( !changes.next ) {
					// If the list contains just one property, don't use the many
					// properties implementation
					notifyPropertyChange( changes.name, changes.oldValue, changes.newValue );
				} else {
					var first: Boolean = _isIterating ? subIterate() : _isIterating = true;
					// Pass the entries to all observers
					var current: PropertyBroadcasterNode = _first;
					while( current ) {
						_next = current._next;
						
						var observer: IPropertyObserver = current._strong;
						if( observer ) {
							observer.onManyPropertiesChanged( _target, changes );
						} else {
							observer = current.weak;
							if( observer ) {
								observer.onManyPropertiesChanged( _target, changes );
							} else {
								removeNode( current );
							}
						}
						current = _next;
					}
					first ? stopIteration() : stopSubIteration();
				}
			}
		}
		
		/**
		 * Notifies all observers about one property that changed.
		 * 
		 * @param name Name of the property that changed
		 * @param oldValue value that the property had prior to that change
		 * @param newValue value that the property has now
		 */
		public function notifyPropertyChange( name: QName, oldValue: *, newValue: * ): void {
			if( _locked ) {
				// If locked don't dispatch
				addToChangeMap( name, oldValue, newValue );
			} else {
				// Send out to all observers
				var first: Boolean = _isIterating ? subIterate() : _isIterating = true;
				var current: PropertyBroadcasterNode = _first;
				while( current ) {
					_next = current._next;
					var observer: IPropertyObserver = current._strong;
					if( observer ) {
						observer.onPropertyChange( _target, name, oldValue, newValue );
					} else {
						observer = current.weak;
						if( observer ) {
							observer.onPropertyChange( _target, name, oldValue, newValue );
						} else {
							removeNode( current );
						}
					}
					current = _next;
				}
				first ? stopIteration() : stopSubIteration();
			}
		}
		
		/**
		 * Offers the possibility to lock/unlock the broadcaster in order to
		 * prevent sending of notifications and merge changes in a object.
		 * 
		 * <p>When unlocking a object all changes will be sen't out as compilated
		 * list.</p>
		 * 
		 * @param locked <code>true</code> if the notifications should be blocked
		 */
		public function set locked( locked: Boolean ): void {
			if( _locked != locked ) {
				_locked = locked;
				if( !locked ) {
					if( _firstChangedNode ) {
						notifyManyPropertiesChanged( _firstChangedNode );
						clearChangeNodes();
					}
				}
			}
		}
		
		public function lock(): void {
			locked = true;
		}
		
		public function unlock(): void {
			locked = false;
		}
		
		public function get locked(): Boolean {
			return _locked;
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
		override protected function set first( node: ListNode ): void {
			_first = PropertyBroadcasterNode( node );
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function get next(): ListNode {
			return _next;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function set next( node: ListNode ): void {
			_next = PropertyBroadcasterNode( node );
		}
		
		/**
		 * Adds the changed property to the list of changed properties
		 * 
		 * @param name name of the property that changed
		 * @param oldValue former value of that property
		 * @param newValue current value of the property
		 */
		private function addToChangeMap( name: QName, oldValue: *, newValue: * ): void {
			if( !_changeMap ) {
				// lazy initialize the map
				_changeMap = {};
			}
			var changeNode: ChangedPropertyNode = _changeMap[ name ];
			if( !changeNode ) {
				// Create a node if necessary and add it to a list
				changeNode = _changeNodePool.getOrCreate();
				changeNode.name = name;
				changeNode.oldValue = oldValue;
				changeNode.prev = _lastChangedNode;
				
				_lastChangedNode = changeNode.addTo( _lastChangedNode );
				
				if( !_firstChangedNode ) _firstChangedNode = changeNode;
				
				_changeMap[ name ] = changeNode;
				_lastChangedNode = changeNode;
			}
			
			changeNode.newValue = newValue;
			
			// If the value changed back to the same value before it was locked
			// remove the node from beeing executed.
			if( changeNode.newValue == changeNode.oldValue ) {
				
				if( _lastChangedNode == changeNode ) _lastChangedNode = changeNode.prev;
				if( _firstChangedNode == changeNode ) _firstChangedNode = changeNode.next;
				
				if( changeNode.next ) changeNode.next.prev = changeNode.prev;
				if( changeNode.prev ) changeNode.prev.next = changeNode.next;
				
				_changeNodePool.returnInstance( changeNode );
				
				delete _changeMap[ name ];
			}
		}
		
		/**
		 * Clear method to be used after a list of changes had been executed or
		 * on disposal.
		 */
		private function clearChangeNodes(): void {
			var current: ChangedPropertyNode = _firstChangedNode;
			while( current ) {
				var next: ChangedPropertyNode = current.next;
				_changeNodePool.returnInstance( current );
				current = next;
			}
			_lastChangedNode = null;
			_firstChangedNode = null;
			_changeMap = null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function addPropertyObserver( observer: IPropertyObserver, weak: Boolean = false ): Boolean {
			return add( observer, weak );
		}
		
		/**
		 * @inheritDoc
		 */
		public function removePropertyObserver( observer: IPropertyObserver ): Boolean {
			return remove( observer );
		}
	}
}
import nanosome.util.access.Changes;
import nanosome.util.pool.IInstancePool;
import nanosome.util.pool.poolFor;

const CHANGES_POOL: IInstancePool = poolFor( Changes );