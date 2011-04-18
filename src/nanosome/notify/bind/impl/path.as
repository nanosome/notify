// @license@
package nanosome.notify.bind.impl {
	
	import nanosome.util.access.qname;
	
	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
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
				var parts: Array = (child as String).split( "." );
				while( parts.length > 0 ) {
					result.push( qname( parts.shift() ) );
				}
			} else if( child is Array ) {
				var childArray: Array = child as Array;
				const m: int = childArray.length;
				for( var j: int = 0; j<m; ++j ) {
					result.push( childArray[j] );
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