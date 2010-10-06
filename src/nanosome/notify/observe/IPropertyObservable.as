// @license@
package nanosome.notify.observe {
	import nanosome.util.IDisposable;
	import nanosome.util.ILockable;
	
	
	/**
	 * <code>IPropertyObservable</code> broadcasts events if any property of the
	 * implementation was changed.
	 * 
	 * <p><code>IPropertyObservable</code> is an alternative to the popular [Bindable]
	 * concept of Flex.</p>
	 * 
	 * <p>There are two major differences between this concept and the [Bindable]
	 * one that allows this implementation to be generally faster.
	 *  <ol>
	 *    <li><strong>No Event objects will be instanciated:</strong><br/>
	 *      No instances will be created to trigger events, this allows less
	 *      memory allocation and faster publication.</li>
	 *    <li><strong>Blocking of notification's and mass changes</strong><br/>
	 *      If you develop a module you have to make sure that every change will
	 *      be processed immediatly. However: If you have a bunch of changes on
	 *      your object done in a row, processing the result for each small change
	 *      might cost a significant amount of processing time. Locking allows
	 *      to tell the module that it should not process the changes until
	 *      the lock has been released.
	 *    </li>
	 *  </ol>
	 * </p>
	 * 
	 * <p>As for now its required that only one property will be changed inside
	 * a change chain. If you plan to change many properties related to each other
	 * use the lock.</p>
	 * 
	 * <p>If instances of <code>IPropertyObservable</code> are locked they have
	 * to store which properties have been locked on which values. In order to
	 * do that in a performing way, linked lists are created which are effectively
	 * circular references that destroy the garbage collection. Call dispose if you
	 * don't need the instance anymore to release those references.</p>
	 * 
	 * <p><small>Note: This is related to the fact that its implementations
	 * use double linked lists for performance enhancements.</small></p>
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @version 1.0
	 * @see IPropertyObserver
	 */
	public interface IPropertyObservable extends IDisposable, ILockable {
		
		/**
		 * Adds a observer to the list of observers.
		 * 
		 * @param observer Observer that should be triggered when changes occur.
		 * @return <code>true</code> if the observer has not been added before
		 */
		function addPropertyObserver( observer: IPropertyObserver ): Boolean;
		
		/**
		 * Removes a observer from the list of observers.
		 * 
		 * @param observer Observer that should not be triggered when changes occur
		 * @return <code>true</code> if the observer was properly removed
		 */
		function removePropertyObserver( observer: IPropertyObserver ): Boolean;
	}
}
