// @license@
package nanosome.notify.field.stage {
	import nanosome.util.DisposableSprite;
	
	
	/**
	 * <code>StageSprite</code> is a default implementation using <code>DOStageAccess</code>
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @version 1.0
	 */
	public class StageSprite extends DisposableSprite {
		
		// Local holder of the access for the properties.
		private var _stageAccess: DOStageAccess;
		
		public function StageSprite() {}
		
		/**
		 * Access for various functions of the stage \
		 */
		public function get stageAccess(): DOStageAccess {
			return _stageAccess || ( _stageAccess = new DOStageAccess( this ) );
		}
		
		override public function dispose(): void {
			if( _stageAccess ) {
				_stageAccess.dispose();
				_stageAccess = null;
			}
			super.dispose();
		}

	}
}
