package nanosome.notify.field.system {
	import nanosome.notify.field.NumberField;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.Dictionary;

	/**
	 * @author mh
	 */
	public class StageProperties {
		
		private static const _registry: Dictionary = new Dictionary( true );
		
		public static function forStage( stage: Stage ): StageProperties {
			return _registry[ stage ] || ( _registry[ stage ] = new StageProperties( stage ) );
		}
		
		public const width: NumberField = new NumberField();
		public const height: NumberField = new NumberField();
		
		public function StageProperties( stage: Stage ) {
			width.value = stage.stageWidth;
			height.value = stage.stageHeight;
			stage.addEventListener( Event.RESIZE, updateSize, false, 0, true );
		}
		
		private function updateSize( event: Event ): void {
			var stage: Stage = Stage( event.target );
			width.value = stage.stageWidth;
			height.value = stage.stageHeight;
		}
	}
}
