// @license@
package nanosome.notify.field {
	
	import nanosome.notify.field.IField;
	
	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public interface IFieldObserver {
		function onFieldChange( field: IField, oldValue: * = null, newValue: * = null ): void;
	}
}
