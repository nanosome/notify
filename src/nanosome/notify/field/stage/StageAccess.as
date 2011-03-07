// @license@ 
package nanosome.notify.field.stage {
	
	import nanosome.notify.field.IBoolField;
	import nanosome.notify.field.INumberField;
	
	import flash.display.Stage;
	
	/**
	 * 
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public final class StageAccess {
		
		private var _stage: Stage;
		
		public function StageAccess( stage: Stage ) {
			_stage = stage;
		}
		
		public function get fullScreen(): IBoolField {
			return broadcasterForStage( _stage ).fullScreen;
		}
		
		public function get fullScreenAvailable(): IBoolField {
			return broadcasterForStage( _stage ).fullScreenAvailable;
		}
		
		public function get stageVideoAvailable(): IBoolField {
			return broadcasterForStage( _stage ).stageVideoAvailable;
		}
		
		public function get mouseX(): INumberField {
			return broadcasterForStage( _stage ).mouseX;
		}
		
		public function get mouseY(): INumberField {
			return broadcasterForStage( _stage ).mouseY;
		}
		
		public function get width(): INumberField {
			return broadcasterForStage( _stage ).width;
		}
		
		public function get height(): INumberField {
			return broadcasterForStage( _stage ).height;
		}
	}
}