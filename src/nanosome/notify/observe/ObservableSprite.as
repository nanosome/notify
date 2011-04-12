// @license@ 
package nanosome.notify.observe {
	import nanosome.util.ChangedPropertyNode;
	import nanosome.util.DisposableSprite;
	import nanosome.util.ILockable;
	import nanosome.util.pool.poolInstance;
	import nanosome.util.pool.returnInstance;
	
	/**
	 * <code>ObservableSprite</code> is a util to easily implement
	 * <code>IPropertyObservable</code> that is based to the Sprite class.
	 * 
	 * <p>The implementation can be handled by simply extending <code>ObservableSprite</code>.
	 * It will be more code that using [Bindable] (as a competing way to achieve that)
	 * but it will be more effient.</p>
	 * 
	 * @example
	 *   <code>
	 *     class MyObservableSprite extends ObservableSprite {
	 *       private var _member: *;
	 *       
	 *       public function set member( member: * ): void {
	 *         if( member != _member ) notifyPropertyChanged( "member", _member, _member = member );
	 *       }
	 *       
	 *       public function get member(): * {
	 *         return _member;
	 *       }
	 *     }
	 *   </code>
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @version 1.0
	 * @see IPropertyObservable
	 */
	public class ObservableSprite
					extends DisposableSprite
					implements IPropertyObservable, ILockable {
		
		// Internal broadcaster used to handle all that heavy lifting
		private var _broadcaster: PropertyBroadcaster;
		
		/**
		 * Constructs the new <code>ObserverableSprite</code>
		 */
		public function ObservableSprite() {}
		
		[Observable]
		override public function set visible( visible: Boolean ): void {
			if( this.visible != visible ) {
				notifyPropertyChange( visibleName, !visible, super.visible = visible );
			}
		}
		
		[Observable]
		override public function set alpha( alpha: Number ): void {
			if( this.alpha != alpha ) {
				notifyPropertyChange( alphaName, this.alpha, super.alpha = alpha );
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose(): void {
			super.dispose();
			if( _broadcaster ) {
				returnInstance( _broadcaster );
				_broadcaster = null;
			}
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
		public final function lock(): void {
			locked = true;
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
		 * Notifies all the observers about a change in object structure.
		 * 
		 * @param name Name of the property that changed
		 * @param oldValue Value that the property had prior to the change
		 * @param newValue Value that the property has now
		 */
		protected function notifyPropertyChange( name: QName, oldValue: *, newValue: * ): void {
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

import nanosome.util.access.qname;

const visibleName: QName = qname( "visible" );
const alphaName: QName = qname( "alpha" );