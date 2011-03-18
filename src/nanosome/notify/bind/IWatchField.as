// @license@ 
package nanosome.notify.bind {
	
	import nanosome.notify.field.IField;
	import nanosome.notify.observe.IPropertyObservable;
	
	/**
	 * A <code>IWatchField</code> defines a <code>IField</code> that 
	 * watches the changes of a property of an object.
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @version 1.0
	 */
	public interface IWatchField extends IField, IPropertyObservable {
		
		/**
		 * Path that is watched.
		 */
		function get path(): String;
		
		/**
		 * Object on whch the path is watched.
		 */
		function get object(): *;
	}
}
