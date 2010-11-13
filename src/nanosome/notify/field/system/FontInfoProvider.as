package nanosome.notify.field.system {
	import nanosome.notify.field.Field;

	/**
	 * @author mh
	 */
	public class FontInfoProvider extends Field {
		
		private var _fontSize: Number = 13.0;
		private var _xSize: Number = 7.0;
		
		public function FontInfoProvider() {
			// TODO: Implement ExternalInterface update logic
		}
		
		public function get fontSize(): Number {
			return _fontSize;
		}
		
		public function get xSize(): Number {
			return _xSize;
		}
	}
}
