// @license@

package nanosome.notify.field.bool {
	import nanosome.notify.field.IBoolField;

	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	internal class OrField extends AndField {
		public function OrField( mos: Array ) {
			super( mos );
		}
		
		override protected function getValue(): Boolean {
			for( var i:int=0; i<_l; ++i ) {
				if( IBoolField( _fields[i] ).isTrue ) {
					return true;
				}
			}
			return false;
		}
	}
}
