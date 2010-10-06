// @license@

package nanosome.notify.bind {
	import nanosome.notify.field.IField;
	import nanosome.notify.observe.IPropertyObservable;

	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public interface IWatchField extends IField, IPropertyObservable {
		function get path(): String;
		function get object(): *;
	}
}
