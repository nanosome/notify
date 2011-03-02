// @license@ 
package nanosome.notify.field {
	
	/**
	 * <code>IBoolField</code> is a more specific version of <code>IField</code>
	 * it should be used once you know for sure that you need to access boolean
	 * functionality of a field.
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @version 1.0
	 */
	public interface IBoolField extends IField {
		
		/**
		 * <code>true</code> if the content results in a <code>true</code> value.
		 */
		function get isTrue(): Boolean;
		
		/**
		 * <code>false</code if the content results in a <code>false</code> value. 
		 */
		function get isFalse(): Boolean;
		
		/**
		 * Switches the value to <code>true</code>.
		 * 
		 * @return <code>true</code> if the value changed.
		 */
		function yes():Boolean;
		
		/**
		 * Switches the value to <code>false</code>.
		 * 
		 * @return <code>true</code> if the value changed.
		 */
		function no():Boolean;
		
		/**
		 * Changes the state from <code>false</code> to <code>true</code>
		 * or from <code>true</code> to <code>false</code>
		 * 
		 * @return current value
		 */
		function flip(): Boolean;
	}
}
