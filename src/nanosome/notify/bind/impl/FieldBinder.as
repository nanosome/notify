// @license@

package nanosome.notify.bind.impl {
	import nanosome.notify.field.IFieldObserver;
	import nanosome.notify.field.IField;
	import nanosome.util.pool.InstancePool;
	import nanosome.util.pools;

	import flash.utils.Dictionary;
	
	
	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public class FieldBinder implements IFieldObserver {
		
		private const _relationMap: Dictionary = new Dictionary();
		private const _listPool: InstancePool = pools.getOrCreate( FieldBindList );
		
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
						fieldB.addObserver(this);
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
		
		public function unbind( field: IField ): IField {
			var relations: FieldBindList = _relationMap[ field ];
			
			// Clear the relations
			_relationMap[ field ] = null;
			
			if( relations && relations.remove( field ) ) {
				// Just check if the list of relations should be checked for its
				// size if something was removed from the list
				if( relations.size == 1 ) {
					// Remove the last MO as well since it is not bound anymore
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
			
			// Unobserve this mo
			field.removeObserver( this );
			return field;
		}
		
		public function onFieldChange( field: IField, oldValue: * = null, newValue: * = null ): void {
			// Use of a central approach to listening because it will not require to add/remove
			// listeners of merged relation lists
			FieldBindList( _relationMap[ field ] ).changeValue( field );
		}
	}
}
