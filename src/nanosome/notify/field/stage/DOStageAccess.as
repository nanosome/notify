// @license@ 
package nanosome.notify.field.stage {
	
	import nanosome.notify.bind.unbindField;
	import nanosome.notify.bind.bindFields;
	import nanosome.notify.field.IBoolField;
	import nanosome.notify.field.INumberField;
	import nanosome.notify.field.NumberField;
	import nanosome.notify.field.bool.BoolField;
	import nanosome.util.UID;
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	
	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public final class DOStageAccess extends UID {
		
		private var _stage: Stage;
		
		internal var _added: BoolField;
		
		internal var _fullScreen: BoolField;
		internal var _fullScreenAvailable: BoolField;
		internal var _stageVideoAvailable: BoolField;
		
		internal var _width: NumberField;
		internal var _height: NumberField;
		internal var _mouseX: NumberField;
		internal var _mouseY: NumberField;
		
		public function DOStageAccess( displayObject: DisplayObject ) {
			displayObject.addEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true );
			displayObject.addEventListener( Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true );
		}
		
		public function get fullScreen(): IBoolField {
			if( !_fullScreen ) {
				_fullScreen = new BoolField( _stage ? _stage.displayState == StageDisplayState.FULL_SCREEN : false );
				if( _stage ) broadcasterForStage( _stage ).add( this );
			}
			return _fullScreen;
		}
		
		public function get fullScreenAvailable(): IBoolField {
			if( !_fullScreenAvailable ) {
				_fullScreenAvailable = new BoolField( false );
				if( _stage ) {
					bindFields( _fullScreenAvailable, broadcasterForStage( _stage ).fullScreenAvailable );
				}
			}
			return _fullScreenAvailable;
		}
		
		public function get stageVideoAvailable(): IBoolField {
			if( !_stageVideoAvailable ) {
				// Of course Adobe forgot about a accessor.... can`t they offer
				// mandatory classes in "How to design a API"?
				var available: Boolean = false;
				if( _stage ) {
					var list: StageChangeBroadcaster = broadcasterForStage( _stage );
					available = list.stageVideoAvailable.isTrue;
				}
				_stageVideoAvailable = new BoolField( available );
				if( _stage ) broadcasterForStage( _stage ).add( this );
			}
			return _stageVideoAvailable;
		}
		
		public function get width(): INumberField {
			if( !_width ) {
				_width = new NumberField( _stage ? _stage.stageWidth : 0.0 );
				if( _stage ) broadcasterForStage( _stage ).add( this );
			}
			return _width;
		}
		
		public function get height(): INumberField {
			if( !_height ) {
				_height = new NumberField( _stage ? _stage.stageHeight : 0.0 );
				if( _stage ) broadcasterForStage( _stage ).add( this );
			}
			return _height;
		}
		
		public function get mouseX(): INumberField {
			if( !_mouseX ) {
				_mouseX = new NumberField( _stage ? _stage.mouseX : 0.0 );
				if( _stage ) broadcasterForStage( _stage ).add( this );
			}
			return _mouseX;
		}
		
		public function get mouseY(): INumberField {
			if( !_mouseY ) {
				_mouseY = new NumberField( _stage ? _stage.mouseY : 0.0 );
				if( _stage ) broadcasterForStage( _stage ).add( this );
			}
			return _mouseY;
		}
		
		public function get added(): IBoolField {
			return _added || ( _added = new BoolField( _stage == null ) );
		}
		
		private function onAddedToStage( event: Event ): void {
			_stage = ( event.target as DisplayObject ).stage;
			
			if( _added ) _added.value = _stage != null;
			if( _mouseX ) _mouseX.setValue( _stage.mouseX );
			if( _mouseY ) _mouseY.setValue( _stage.mouseY );
			if( _width ) _width.setValue( _stage.stageWidth );
			if( _height ) _height.setValue( _stage.stageHeight );
			if( _fullScreen ) _fullScreen.setValue( _stage.displayState == StageDisplayState.FULL_SCREEN );
			if( _fullScreenAvailable ) {
				bindFields( broadcasterForStage( _stage ).fullScreenAvailable, _fullScreenAvailable );
			}
			if( _stageVideoAvailable ) {
				_stageVideoAvailable.setValue(
					broadcasterForStage( _stage ).stageVideoAvailable.isTrue
				);
			}
			if( _mouseX || _mouseY || _width || _height ) {
				broadcasterForStage( _stage ).add( this );
			}
		}
		
		public function dispose(): void {
			if( _stage && ( _mouseX || _mouseY || _width || _height ) ) {
				broadcasterForStage( _stage ).remove( this );
			}
			if( _added ) { _added.dispose(); _added = null; }
			if( _mouseX ) { _mouseX.dispose(); _mouseX = null; }
			if( _mouseY ) { _mouseY.dispose(); _mouseY = null; }
			if( _width ) { _width.dispose(); _width = null; }
			if( _height ) { _height.dispose(); _height = null; }
			if( _fullScreen ) { _fullScreen.dispose(); _fullScreen = null; }
			if( _fullScreenAvailable ) {
				unbindField( _fullScreenAvailable );
				_fullScreenAvailable.dispose();
				_fullScreenAvailable = null;
			}
			if( _stageVideoAvailable ) {
				_stageVideoAvailable.dispose();
				_stageVideoAvailable = null;
			}
		}
		
		private function onRemovedFromStage( event: Event ): void {
			if( _mouseX || _mouseY || _width || _height ) {
				broadcasterForStage( _stage ).remove( this );
			}
			if( _fullScreenAvailable ) {
				unbindField( _fullScreenAvailable );
			}
			if( _added ) _added.value = false;
			_stage = null;
		}
	}
}
