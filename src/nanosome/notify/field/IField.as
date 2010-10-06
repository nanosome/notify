// @license@

package nanosome.notify.field {
	import nanosome.util.IUID;
	
	
	/**
	 * <code>IField</code> is a basic concept in nanosome to reduce complexity of code.
	 * 
	 * <p>In <abbr title="ActionScript 3">AS3</abbr> code it is common to distribute
	 * changes of a value as event. The use of <code>IField</code> is a effective way
	 * to reduce the complexity for the change of fields.</p>
	 * 
	 * <p><i>Explanation by example:</i> A change of the <code>mouseX</code> value
	 * of a <code>DisplayObject</code> is distributed to possible listeners by a
	 * <code>MouseEvent</code> sent from the owner. Now: there are two seperate
	 * informations necessary to properly track the changes and the current
	 * state of the value:</p>
	 * <ol>
	 *   <li>Which event will be sent on the change of the value?
	 *       <i><code>DisplayObject.addEventListener(MouseEvent.MOUSE_MOVE)</code></i></li>
	 *   <li>How can the value be accessed? <i><code>DisplayObject.mouseX</code></i></li>
	 * </ol>
	 * 
	 * <p>Writing code specific to this event and to the value might be usable but
	 * the code written is strongly tight to this value. This <i>(In trivial words: Your
	 * effect will be bound to the <code>mouseX</code> value, binding it to
	 * any other property might require you to rename pretty much every method,
	 * access)</i></p>
	 * 
	 * <p>Any <code>IField</code> presents the access to the current value reading
	 * and (possibly) writing. Changes of this value are dispatched to <code>IFieldObserver</code>
	 * instances.</p>
	 * 
	 * <p>A simple implementation of <code>IField</code> is available as <code>Field</code>.</p>
	 * 
	 * @example Example of how to use a field
	 *    <listening>
	 *    import nanosome.field.IFieldObserver;
	 *    import nanosome.field.IField;
	 *    
	 *    class MyClass implements IFieldObserver {
	 *      
	 *      private var _field: IField;
	 *      
	 *      public function MyClass( field: IField ) {
	 *        _field = field;
	 *        _field.addObserver( this, true );
	 *      }
	 *      
	 *      public function onFieldChange( field: IField, newValue: * = null, oldValue: * = null ): void {
	 *        if( field == _field ) {
	 *          trace( Number( _field.value ) + 1 );
	 *        }
	 *      }
	 *    }
	 *    </listening>
	 * 
	 * <p>A <code>IField</code> also has to send a change event if <code>IChangeable</code>
	 * changed from one value to another.</p>
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @see nanosome.bind.field.Field
	 * @see nanosome.bind.field.IFieldObserver
	 * @see nanosome.bind.observer#PropertyChangeWatcher
	 * @see nanosome.bind#bindFields()
	 * @see nanosome.bind#unbindField()
	 */
	public interface IField extends IUID {
		
		/**
		 * The value of this <code>IField</code>
		 */
		function get value(): *;
		
		/**
		 * Convenient access to <code>setValue</code>.
		 * 
		 * @see #setValue()
		 */
		function set value( value: * ): void;
		
		/**
		 * Access to change the value of this Micro Observable.
		 * 
		 * <p><code>setValue</code> has a strong contract with <code>value</code>
		 * </p>
		 * 
		 * @param value that should be changed
		 * @return <code>true</code> if the value has been successfully changed
		 * @see #value
		 */
		function setValue( value: * ): Boolean;
		
		/**
		 * <code>true</code> if this <code>Field</code> may be changed. If <code>false</code>
		 * then <code>setValue</code> or <code>value=</code> are allowed to throw an error.
		 * This property may change over time. It is necessary to check it on every
		 * access.
		 */
		function get isChangeable(): Boolean;
		
		/**
		 * @param observer Observer that wants to track the changes of the value
		 * @param executeImmediatly 
		 * @param weakReference 
		 * @return <code>true</code> if the operation changed the observers list
		 */
		function addObserver( observer: IFieldObserver, executeImmediatly: Boolean = false,
									weakReference: Boolean = false ): Boolean;
		
		/**
		 * @param observer Observer that wants to track the changes of the value
		 * @return <code>true</code> if the operation changed the observers list
		 */
		function removeObserver( observer: IFieldObserver ): Boolean;
		
		/**
		 * 
		 * @return <code>true</code> if the operation changed the observers list
		 */
		function hasObserver( observer: IFieldObserver ): Boolean;
	}
	
}
