// @license@ 
package nanosome.notify.bind {
	
	import nanosome.notify.field.IField;
	import nanosome.notify.observe.IPropertyObservable;
	
	/**
	 * A <code>IWatchField</code> defineds a <code>IField</code>
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * 
	 */
	public interface IWatchField extends IField, IPropertyObservable {
		function get path(): String;
		function get object(): *;
	}
}
