// @license@
package nanosome.notify.bind.impl {
	
	import nanosome.notify.field.IField;
	import nanosome.notify.field.IFieldObserver;
	import nanosome.util.pool.IInstancePool;
	import nanosome.util.pool.poolFor;
	
	import flash.utils.Dictionary;
	
	/**
	 * <code>FieldBinder</code> is the default mechanism for binding.
	 * 
	 * <p><code>FieldBinder</code> binds, as the name suggests, <code>IField</code>
	 * instances to each-other. Binding means that whenever the content of one
	 * field changes, all bound fields change as well.</p>
	 * 
	 * <p>The <code>FieldBinder</code> supports weak binding as well as masters in
	 * binding nodes. A &quot;master&quot; is a field that is not changeable. The
	 * <code>FieldBinder</code> will respect that and any connect field that changes
	 * will be immediately set back to the value of the master.</p>
	 * 
	 * <p>For fields that are changeable but should still be treated as master
	 * nodes its possible to state that while binding.</p>
	 * 
	 * <p class="warning">Warning: In case two masters/unchangeable fields are bound
	 * together, a runtime exception will be raised!</p>
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @see nanosome.notify.field.IField
	 * @see nanosome.notify.field.IField#isChangable
	 */
	public class FieldBinder implements IFieldObserver {
		
		// Stores which fields are bound together.
		protected const _relationMap: Dictionary /* IField -> FieldBindList */ = new Dictionary();
		
		// Pool of lists to be used.
		protected const _listPool: IInstancePool = poolFor( FieldBindList );
		
		/**
		 * Constructs a new <code>FieldBinder</code>.
		 */
		public function FieldBinder() {
			super();
		}
		
		/**
		 * Binds two fields together.
		 * 
		 * <p>If one or both of the fields have been bound before, all fields will
		 * be bound together.</p>
		 * 
		 * @param fieldA First <code>IField</code> to bind
		 * @param fieldB Second <code>IField</code> to bind
		 * @param bidirectional If set to false it will use the <code>fieldA</code> as master
		 * @return <code>fieldA</code> that was passed-in
		 */
		public function bind( fieldA: IField, fieldB: IField, bidirectional: Boolean = true ): IField {
			if( fieldA != null && fieldB != null ) {
				var relationsA: FieldBindList = _relationMap[ fieldA ];
				var relationsB: FieldBindList = _relationMap[ fieldB ];
				if( relationsA ) {
					if( relationsB ) {
						// Both fieldss have been registered before,
						if( relationsA != relationsB ) {
							// Both fields have been registered to different groups
							// now both groups need to be merged to one group
							
							var unchangableA: Boolean = relationsA.unchangable && !relationsA.unchangable.isChangeable;
							var unchangableB: Boolean = relationsB.unchangable && !relationsB.unchangable.isChangeable;
							
							if( unchangableA && unchangableB ) {
								throw new Error( "Trying to bind fields where at least two fields"
														+ " are unchangable: '" + relationsA.unchangable + "' and"
														+ " '" + relationsB.unchangable + "'; cross-lock");
							}
							if( (unchangableA || unchangableB) && ( !bidirectional || relationsA.master || relationsB.master ) ) {
								throw new Error( "Trying to apply uni-directional binding while"
													+ " it was already bound to a unchangable field '"
													+ (relationsA.unchangable || relationsB.unchangable) + "'; cross-lock" );
							}
							
							// Use fieldA as master field
							if( !bidirectional ) {
								relationsA.master = fieldA;
							}
							
							// all entries in second list need to be added to first list
							var currentNode: FieldBindListNode = relationsB.firstNode;
							while( currentNode ) {
								_relationMap[ currentNode.field ] = relationsA;
								relationsA.add( currentNode.field );
								currentNode = currentNode.nextNode;
							}
							
							// now relationsB can be returned to the pool
							_listPool.returnInstance( relationsB );
						} else if( !bidirectional ) {
							relationsA.master = fieldA;
						}
						// all relations are taken care of, fast return
						return fieldA;
					} else {
						// Add the fieldB that didn't belong to a group to the same group
						// as fieldA
						relationsA.add( fieldB );
						_relationMap[ fieldB ] = relationsA;
						fieldB.addObserver( this );
						// Note as master in case it ain't by now already
						if( !bidirectional ) {
							relationsA.master = fieldA;
						}
					}
				} else if( relationsB ) {
					// Add the fieldA that didn't belong to a group to the same group
					// as fieldB
					// but first take care that the value of fieldA is taken
					if( !bidirectional ) {
						relationsB.master = fieldA;
					} else {
						relationsB.changeValue( fieldA );
					}
					relationsB.add( fieldA );
					_relationMap[ fieldA ] = relationsB;
					fieldA.addObserver( this );
				} else {
					// Add both fields to a new pool
					relationsA = _listPool.getOrCreate();
					try {
						relationsA.add( fieldA );
						if( !bidirectional ) {
							relationsA.master = fieldA;
						}
						relationsA.add( fieldB );
						fieldA.addObserver( this );
						fieldB.addObserver( this );
						_relationMap[ fieldA ] = relationsA;
						_relationMap[ fieldB ] = relationsA;
					} catch( e: Error ) {
						// In case an error exists, the list is no where
						// registered and its free to be just returned.
						_listPool.returnInstance( relationsA );
						throw e;
					}
				}
			}
			return fieldA;
		}
		
		/**
		 * Releases a <code>IField</code> from all bindings.
		 * 
		 * <p>In case the field was bound before it will not take over any changes
		 * anymore.</p>
		 * 
		 * <p>In case it wasn`t bound before, nothing will happen, it will just
		 * be returned.</p>
		 * 
		 * <p>If it was bound to exactly one other field, also the other field
		 * will be released from binding.</p>
		 * 
		 * @param field <code>IField</code> to be unbound
		 * @return the passed-in <code>IField</code>
		 */
		public function unbind( field: IField ): IField {
			var relations: FieldBindList = _relationMap[ field ];
			
			// Clear the relations
			_relationMap[ field ] = null;
			
			if( relations && relations.remove( field ) ) {
				// Just check if the list of relations should be checked for its
				// size if something was removed from the list
				if( relations.size == 1 ) {
					// Remove the last field as well since it is not bound anymore
					var lastField: IField = relations.firstNode.field;
					_relationMap[ lastField ] = null;
					relations.remove( lastField );
					lastField.removeObserver( this );
				}
				// Since the list will be empty if empty or .
				if( relations.empty ) {
					_listPool.returnInstance( relations );
				}
			}
			
			// Unobserve this field
			field.removeObserver( this );
			return field;
		}
		
		/**
		 * Implementation of <code>IFieldObserver</code>. Passes the changes
		 * of one field to all bound fields.
		 * 
		 * @param field <code>IField</code> that had some change
		 * @param oldValue the former value of the field
		 * @param newValue the new value of the field
		 * @see IFieldObserver#onFieldChange
		 */
		public function onFieldChange( field: IField, oldValue: * = null, newValue: * = null ): void {
			// Use of a central approach to listening because it will not require to add/remove
			// listeners of merged relation lists
			FieldBindList( _relationMap[ field ] ).changeValue( field );
		}
	}
}
