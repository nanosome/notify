// @license@ 
package nanosome.notify.field.bool {
	
	import nanosome.notify.field.IBoolField;
	import nanosome.notify.field.IField;
	
	/**
	 * Transforms the input into a <code>IBoolField</code>.
	 * 
	 * @param input Value to be transformed
	 * @return <code>IBoolField</code> that eigther contains or refers to the value.
	 * @author Martin Heidegger
	 * @version 1.0
	 */
	public function bool( input: * ): IBoolField {
		if( input is IBoolField ) {
			return input;
		} else if( input is IField ) {
			return new BoolFieldWrapper( IField( input ) );
		} else {
			return new BoolField( input, true );
		}
	}
}
