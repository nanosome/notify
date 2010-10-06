// @license@
package nanosome.notify.observe {
	import nanosome.util.ChangedPropertyNode;
	import nanosome.util.IUID;
	
	/**
	 * <code>IPropertyObserver</code> defines observers to listen on changes of
	 * objects that contain properties.
	 * 
	 * <p>Whilst directly used by <code>IPropertyObservable</code>, this definition
	 * is not bound to it. It can also be used to track changes in [Bindable] or
	 * foreign constructs if a implementation supports that.</p>
	 * 
	 * <p><code>ChangeWatcher</code> as a example supports mixed use of [Bindable]
	 * as well as <code>IPropertyObservable</code> instances.</p>
	 * 
	 * <p>In order to have fast performing events handled for a lot of changes in
	 * a object the handlers for <code>IPropertyObserver</code> implementations
	 * dispatch a list of changes as a list of <code>ChangedPropertyNode</code>'s</p>
	 * 
	 * @example
	 *   <code>
	 *     class ExampleObserver implements IPropertyObserver {
	 *       // ...
	 *       public function onManyPropertiesChanged( observable: *, changes: ChangedPropertyNode ): void {
	 *         var change: ChangedPropertyNode = changes;
	 *         while( change ) {
	 *           trace( change.name, change.oldValue, change.newValue );
	 *           change = change.next;
	 *         }
	 *       }
	 *     }
	 *   </code>
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @version 1.0
	 * @see IPropertyObservable
	 * @see ChangedPropertyNode
	 * @see watch
	 */
	public interface IPropertyObserver extends IUID {
		
		/**
		 * Triggered if one property of a instance changed.
		 * 
		 * <p>Its recommended to not access the instance's properties but the
		 * passed-in values in order to allow implementations to trick if they
		 * want to.</p>
		 * 
		 * @param observable instance which's property changed
		 * @param propertyName name of the property that changed
		 * @param newValue new value of the observable
		 * @param oldValue old value of the observable
		 */
		function onPropertyChange( observable: *, propertyName: String, oldValue: *, newValue: * ): void;
		
		/**
		 * Triggered if many properties of the instance changed.
		 * 
		 * @example
		 *   <listing>
		 *     class ExampleObserver implements IPropertyObserver {
		 *        //...
		 *        public function onManyPropertiesChanged( observable: *, changes: ChangedPropertyNode ): void {
		 *           var change: ChangedPropertyNode = changes;
		 *           while( change ) {
		 *             trace( observable, change.name, change.oldValue, change.newValue );
		 *             change = change.next;
		 *           }
		 *        }
		 *     }
		 *   </listing>
		 * 
		 * @param observable instance which's properties changed
		 * @param changes The first node of properties that changed
		 * @see ChangedPropertyNode
		 */
		function onManyPropertiesChanged( observable: *, changes: ChangedPropertyNode ): void;
	}
}
