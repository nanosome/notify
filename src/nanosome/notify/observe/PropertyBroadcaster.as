// @license@
package nanosome.notify.observe {
	import nanosome.util.ChangedPropertyNode;
	import nanosome.util.EnterFrame;
	import nanosome.util.ILockable;
	import nanosome.util.access.Accessor;
	import nanosome.util.access.accessFor;
	import nanosome.util.list.List;
	import nanosome.util.list.ListNode;
	import nanosome.util.pool.InstancePool;
	import nanosome.util.pools;

	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
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
		private static const _changeNodePool: InstancePool =
				pools.getOrCreate( ChangedPropertyNode );
		
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
		
		private var _accessor: Accessor;
		
		private var _storage : Object;
		private var _nonSendingFields : Array;
		private var _observedFields : Array;
		
		/**
		 * Creates a new instance of the <code>PropertyBroadcaster</code>
		 * 
		 * @param target Target to be used on initialization of the instance
		 */
		public function PropertyBroadcaster( target: * = null ) {
			super( pools.getOrCreate( PropertyBroadcasterNode ) );
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
			if( _target != target ) {
				if( _target && _target is IEventDispatcher ) {
					IEventDispatcher( _target ).removeEventListener( "propertyChange", onPropertyChange );
				}
				_target = target;
				_nonSendingFields = null;
				if( _target ) {
					_accessor = accessFor( _target );
					if( _accessor.nonEventSendingProperties ) {
						_nonSendingFields = _accessor.nonEventSendingProperties.concat();
					}
				} else {
					_accessor = null;
				}
				checkListening();
			}
		}
		
		public function get target(): * {
			return _target;
		}
		
		private function checkListening(): void {
			if( !empty && hasObserverToNonSendingField ) {
				if( EnterFrame.add( checkNonEventSending ) ) {
					_storage = _accessor.readAll( _target, _nonSendingFields );
				}
			} else {
				_storage = null;
				EnterFrame.remove( checkNonEventSending );
			}
			
			if( _target is IEventDispatcher ) {
				if( !empty && _accessor && _accessor.hasBindable ) {
					IEventDispatcher( _target ).addEventListener( "propertChange", onPropertyChange );
				} else {
					IEventDispatcher( _target ).removeEventListener( "propertyChange", onPropertyChange );
				}
			}
		}
		
		private function get hasObserverToNonSendingField(): Boolean {
			if( _observedFields && _accessor ) {
				var i: int = _observedFields.length;
				while( --i - (-1) ) {
					if( !_accessor.isSendingChangeEvent( _observedFields[i] ) ) {
						return true;
					}
				}
			}
			return false;
		}
		
		public function observeField( name: String ): void {
			if( !_observedFields ) {
				_observedFields = [];
			}
			if( _observedFields.indexOf( name ) == -1 ) {
				_observedFields.push( name );
				checkListening();
			}
		}
		
		public function unobserveField(name : String): void {
			if( _observedFields ) {
				var pos : int = _observedFields.indexOf(name);
				if( pos != -1 ) {
					_observedFields.splice(pos, 1);
					if( _observedFields.length == 0 ) {
						_observedFields = null;
					}
					checkListening();
				}
			}
		}
		
		private function checkNonEventSending(): void {
			var changes: ChangedPropertyNode = _accessor.compareWithStorage( _target, _storage );
			if( changes ) {
				notifyManyPropertiesChanged( changes );
			}
		}
		
		private function onPropertyChange( event: Event ): void {
			notifyPropertyChange( event["property"], event["oldValue"], event["newValue"] );
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
					startIterate();
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
					stopIterate();
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
		public function notifyPropertyChange( name: String, oldValue: *, newValue: * ): void {
			if( _locked ) {
				// If locked don't dispatch
				addToChangeMap( name, oldValue, newValue );
			} else {
				// Send out to all observers
				startIterate();
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
				stopIterate();
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
		private function addToChangeMap( name: String, oldValue: *, newValue: * ): void {
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
		
		public function addPropertyObserver( observer: IPropertyObserver ): Boolean {
			return add( observer );
		}
		
		public function removePropertyObserver( observer: IPropertyObserver ): Boolean {
			return remove( observer );
		}
	}
}