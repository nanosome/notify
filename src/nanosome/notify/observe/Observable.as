// @license@ 
package nanosome.notify.observe {
	import nanosome.util.ChangedPropertyNode;
	import nanosome.util.ILockable;
	import nanosome.util.IUID;
	import nanosome.util.UID;
	import nanosome.util.pool.poolInstance;
	import nanosome.util.pool.returnInstance;
	
	
	
	/**
	 * <code>Observable</code> is a util to easily implement <code>IPropertyObservable</code>.
	 * 
	 * <p>The implementation can be handled by simply extending <code>Observable</code>. It
	 * will be more code that using [Bindable] (as a competing way to achieve that)
	 * but it will be more effient.</p>
	 * 
	 * @example
	 *   <code>
	 *     class MyObservable extends Observable {
	 *       private var _member: *;
	 *       
	 *       public function set member( member: * ): void {
	 *         if( member != _member ) notifyPropertyChanged( Q_member, _member, _member = member );
	 *       }
	 *       
	 *       public function get member(): * {
	 *         return _member;
	 *       }
	 *     }
	 *     
	 *     import nanosome.util.access.qname;
	 *     
	 *     private const Q_member: QName = qname( "member" );
	 *     // for performance reasons we store the access to the member locally
	 *   </code>
	 * 
	 * <p>If a <code>Observable</code> is <code>locked</code> it will store all 
	 * the changes and deploy them upon release.</p>
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @version 1.0
	 * @see IPropertyObservable
	 */
	public class Observable
					extends UID
					implements IPropertyObservable, ILockable, IUID {
		
		// Internal broadcaster used to handle all that heavy lifting
		protected var _broadcaster: PropertyBroadcaster = new PropertyBroadcaster();
		
		/**
		 * Constructs the new <code>Observerable</code>
		 */
		public function Observable() {
			_broadcaster.target = this;
		}
		
		/**
		 * @inheritDoc
		 */
		public function dispose(): void {
			if( _broadcaster ) {
				returnInstance( _broadcaster );
				_broadcaster = null;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public final function lock(): void {
			locked = true;
		}
		
		/**
		 * @inheritDoc
		 */
		public final function unlock(): void {
			locked = false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set locked( locked: Boolean ): void {
			if( !_broadcaster && locked  ) {
				_broadcaster = poolInstance( PropertyBroadcaster );
				_broadcaster.target = this;
			}
			if( _broadcaster ) {
				_broadcaster.locked = locked;
				if( !locked && _broadcaster.empty ) {
					returnInstance( _broadcaster );
					_broadcaster = null;
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function get locked(): Boolean {
			if( _broadcaster ) {
				return _broadcaster.locked;
			} else {
				return false;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public final function addPropertyObserver( observer: IPropertyObserver, weak: Boolean = false ): Boolean {
			if( !_broadcaster ) {
				_broadcaster = poolInstance( PropertyBroadcaster );
				_broadcaster.target = this;
			}
			return _broadcaster.add( observer, weak );
		}
		
		/**
		 * @inheritDoc
		 */
		public final function removePropertyObserver( observer: IPropertyObserver ): Boolean {
			if( _broadcaster ) {
				var removed: Boolean = _broadcaster.remove( observer );
				if( removed && _broadcaster.empty ) {
					returnInstance( _broadcaster );
					_broadcaster = null;
				}
				return removed;
			} else {
				return false;
			}
		}
		
		/**
		 * Notifies all the observers about a change
		 * 
		 * @param name Name of the property that changed
		 * @param oldValue Value that the property had prior to the change
		 * @param newValue Value that the property has now
		 */
		protected  function notifyPropertyChange( name: QName, oldValue: *, newValue: * ): void {
			if( _broadcaster ) _broadcaster.notifyPropertyChange( name, oldValue, newValue );
		}
		
		/**
		 * Notifies all the observers about a list of changes in object structure.
		 * 
		 * @param changes Changes that occured
		 */
		protected function notifyManyPropertiesChanged( changes: ChangedPropertyNode ): void {
			if( _broadcaster ) _broadcaster.notifyManyPropertiesChanged( changes );
		}
	}
}
