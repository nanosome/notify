// @license@
package nanosome.notify.field {

	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public interface IFieldObserver {
		function onFieldChange( mo: IField, oldValue: * = null, newValue: * = null ): void;
	}
}
