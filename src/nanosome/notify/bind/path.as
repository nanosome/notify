// @license@
package nanosome.notify.bind {
	
	import nanosome.util.access.qname;
	
	/**
	 * Creates a list of <code>QName</code> instances that point to a deep path
	 * of a object.
	 * 
	 * <p>Since namespaces may contain dots (.), the only character required for
	 * namespaces, it is useful to have this method which prepares a list of
	 * <code>QName</code> entries a a replacement.</p>
	 * 
	 * <p>This method allows a lot of ways to be used. For example it is possible to
	 * just pass in a list of strings.</p>
	 * <listing version="3">
	 *   path( "a", "b", "c" ); // [ [QName(a), QName(b), QName(c) ]
	 * </listing>
	 * 
	 * <p>That is equal to passing a the same with dots.</p>
	 * <listing version="3">
	 *   path( "a.b.c" ); // [ [QName(a), QName(b), QName(c) ]
	 * </listing>
	 * 
	 * <p>You can even mix it.</p>
	 * <listing version="3">
	 *   path( "a.b", "c" ); // [ [QName(a), QName(b), QName(c) ]
	 * </listing>
	 * 
	 * <p>If you need a namespace, you can just add it with a "::".</p>
	 * <listing version="3">
	 *   path( "foo.bar::a", "b", "c" ); // [ [QName(foo.bar::a), QName(b), QName(c) ]
	 * </listing>
	 * 
	 * <p>You can still define another property after the name.</p>
	 * <listing version="3">
	 *   path( "foo.bar::a.b", "c" ); // [ [QName(foo.bar::a), QName(b), QName(c) ]
	 * </listing>
	 * 
	 * <p>Its also possible to just pass a array of names.</p>
	 * <listing version="3">
	 *   path( "foo.bar::a.b", "c" ); // [ [QName(foo.bar::a), QName(b), QName(c) ]
	 * </listing>
	 * 
	 * <p>Warning: If you add just array it will simply return that. This has been
	 * made for the case that someone passes a already defined namespace list.</p>
	 * <listing version="3">
	 *   path( [ qname("foo.bar::a"), qname("b"), qname("c") ] ) ); // [ [QName(foo.bar::a), QName(b), QName(c) ]
	 * </listing>
	 * 
	 * @param elements A list of path entries
	 * @return a list of QName instances
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @version 1.0
	 */
	public function path( ...elements: Array ): Array {
		const l: int = elements.length;
		if( l == 1 && elements[0] is Array ) {
			return elements[0];
		}
		var result: Array = [];
		for( var i: int = 0; i < l; ++i ) {
			var child: * = elements[ i ];
			if( child is String ) {
				var str: String = child;
				var index: int;
				while( ( index = str.indexOf("::") ) != -1 ) {
					var index2: int = str.indexOf( ".", index );
					if( index2 != -1 ) {
						result.push( qname( str.substr( 0, index2 ) ) );
						str = str.substr( index2 + 1 );
					} else {
						result.push( qname( str ) );
						str = null;
						break;
					}
				}
				if( str ) {
					var parts: Array = str.split( "." );
					while( parts.length > 0 ) {
						result.push( qname( parts.shift() ) );
					}
				}
			} else if( child is Array ) {
				var childArray: Array = child as Array;
				const m: int = childArray.length;
				for( var j: int = 0; j<m; ++j ) {
					result.push( qname( childArray[j] ) );
				}
			} else if( child is QName ) {
				result.push( child );
			} else {
				throw new Error("Can not create path for "+ child );
			}
		}
		return result;
	}
}