// @license@ 
package nanosome.notify.field.stage {
	
	import nanosome.notify.field.IBoolField;
	import nanosome.notify.field.INumberField;
	import nanosome.notify.field.NumberField;
	import nanosome.notify.field.bool.BoolField;
	import nanosome.util.list.UIDList;
	import nanosome.util.list.UIDListNode;
	import nanosome.util.pool.poolFor;

	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	
	
	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	internal class StageChangeBroadcaster extends UIDList {
		
		public static const FULLSCREEN_FLASH_VAR: String = "fullScreen";
		
		private var _first: ChangeBroadcasterNode;
		private var _next: ChangeBroadcasterNode;
		
		private var _stage: Stage;
		
		private var _fullScreen: BoolField;
		private var _fullScreenAvailable: BoolField;
		private var _stageVideoAvailable: BoolField;
		private var _width: NumberField;
		private var _height: NumberField;
		private var _mouseX: NumberField;
		private var _mouseY: NumberField;
		
		public function StageChangeBroadcaster( stage: Stage ) {
			super( poolFor( ChangeBroadcasterNode ) );
			_stage = stage;
			_stage.addEventListener( Event.RESIZE, updateSize, false, 0, false );
			_stage.addEventListener( MouseEvent.MOUSE_MOVE, updateMousePos, false, 0, false );
			_stage.addEventListener( FullScreenEvent.FULL_SCREEN, updateFullScreen, false, 0, false );
			_stage.addEventListener( "stageVideoAvailability", updateStageVideoAvailable, false, 0, false );
		}
		
		public function get width(): INumberField {
			return _width || ( _width = new NumberField( _stage.stageWidth ) );
		}
		
		public function get height(): INumberField {
			return _height || ( _height = new NumberField( _stage.stageHeight ) );
		}
		
		public function get mouseX(): INumberField {
			return _mouseX || ( _mouseX = new NumberField( _stage.mouseX ) );;
		}
		
		public function get mouseY(): INumberField {
			return _mouseY || ( _mouseY = new NumberField( _stage.mouseY ) );
		}
		
		public function get fullScreenAvailable(): IBoolField {
			if( !_fullScreenAvailable ) {
				_fullScreenAvailable = new BoolField( false );
				try {
					_fullScreenAvailable.setValue( _stage["fullScreenAvailable"] );
				} catch( e: Error ) {
					var fullScreen: String = _stage.loaderInfo.parameters[ FULLSCREEN_FLASH_VAR ];
					_fullScreenAvailable.setValue( fullScreen && fullScreen.toLowerCase() == "true" );
				};
			}
			return _fullScreenAvailable;
		}
		
		public function get fullScreen(): IBoolField {
			return _fullScreen || ( _fullScreen = new BoolField( _stage.displayState == StageDisplayState.FULL_SCREEN ) );
		}
		
		public function get stageVideoAvailable(): IBoolField {
			if( !_stageVideoAvailable ) {
				_stageVideoAvailable = new BoolField();
			}
			return _stageVideoAvailable;
		}
		
		private function updateStageVideoAvailable( event: Event ): void {
			const available: Boolean = event["availability"] == "available";
			stageVideoAvailable.setValue( available );
			
			var current: ChangeBroadcasterNode = _first;
			while( current ) {
				_next = current._next;
				var access: DOStageAccess = current._strong;
				if( access != null ) {
					if( access._stageVideoAvailable )
						access._stageVideoAvailable.setValue( available );
				} else {
					access = current.weak;
					if( access != null ) {
						if( access._stageVideoAvailable )
							access._stageVideoAvailable.setValue( available );
					} else {
						removeNode( current );
					}
				}
				current = _next;
			}
		}
		
		private function updateMousePos( e: Event ): void {
			const x: Number = _stage.mouseX;
			const y: Number = _stage.mouseY;
 			if( _mouseX ) _mouseX.setValue( x );
			if( _mouseY ) _mouseY.setValue( y );
			
			var current: ChangeBroadcasterNode = _first;
			while( current ) {
				_next = current._next;
				var access: DOStageAccess = current._strong;
				if( access != null ) {
					if( access._mouseX ) access._mouseX.setValue( x );
					if( access._mouseY ) access._mouseY.setValue( y );
				} else {
					access = current.weak;
					if( access != null ) {
						if( access._mouseX ) access._mouseX.setValue( x );
						if( access._mouseY ) access._mouseY.setValue( y );
					} else {
						removeNode( current );
					}
				}
				current = _next;
			}
		}
		
		private function updateSize( e: Event ): void {
			const width: Number = _stage.stageWidth;
			const height: Number = _stage.stageHeight;
			if( _width ) _width.setValue( width );
			if( _height ) _height.setValue( height );
			
			var current: ChangeBroadcasterNode = _first;
			while( current ) {
				_next = current._next;
				var access: DOStageAccess = current._strong;
				if( access != null ) {
					if( access._width ) access._width.setValue( width );
					if( access._height ) access._height.setValue( height );
				} else {
					access = current.weak;
					if( access != null ) {
						if( access._width ) access._width.setValue( width );
						if( access._height ) access._height.setValue( height );
					} else {
						removeNode( current );
					}
				}
				current = _next;
			}
		}
		
		private function updateFullScreen( e: Event ): void {
			
			const fullScreen: Boolean = ( _stage.displayState == StageDisplayState.FULL_SCREEN );
			if( _fullScreen ) _fullScreen.setValue( fullScreen );
			if( _fullScreenAvailable ) _fullScreenAvailable.setValue( true );
			
			var current: ChangeBroadcasterNode = _first;
			while( current ) {
				_next = current._next;
				var access: DOStageAccess = current._strong;
				if( access != null ) {
					if( access._fullScreen ) access._fullScreen.setValue( fullScreen );
					if( fullScreen && access._fullScreenAvailable )
						access._fullScreenAvailable.setValue( true );
				} else {
					access = current.weak;
					if( access != null ) {
						if( access._fullScreen ) access._fullScreen.setValue( fullScreen );
						if( fullScreen && access._fullScreenAvailable )
							access._fullScreenAvailable.setValue( true );
					} else {
						removeNode( current );
					}
				}
				current = _next;
			}
		}
		
		override protected function get first(): UIDListNode {
			return _first;
		}
		
		override protected function set first( node: UIDListNode ): void {
			_first = ChangeBroadcasterNode( node );
		}
		
		override protected function get next(): UIDListNode {
			return _next;
		}
		
		override protected function set next( node : UIDListNode ): void {
			_next = ChangeBroadcasterNode( node );
		}
	}
}

import nanosome.notify.field.stage.DOStageAccess;
import nanosome.util.IUID;
import nanosome.util.list.UIDListNode;

class ChangeBroadcasterNode extends UIDListNode {
	
	internal var _strong: DOStageAccess;
	internal var _next: ChangeBroadcasterNode;
	
	public function ChangeBroadcasterNode() {}

	
	override public function set strong( content: IUID ): void {
		_strong = DOStageAccess( content );
	}
	
	override public function get strong(): IUID {
		return _strong;
	}
	
	override public function set next( node: UIDListNode ): void {
		_next = ChangeBroadcasterNode( node );
		super.next = node;
	}
}
