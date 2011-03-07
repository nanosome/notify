package nanosome.notify.field {
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import flexunit.framework.TestCase;
	import nanosome.notify.field.stage.StageAccess;
	import nanosome.notify.field.stage.StageSprite;
	import nanosome.notify.field.stage.accessForStage;



	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public class SpriteTest extends TestCase {
		
		private var _sprite: StageSprite;
		private var _props: StageAccess;
		private var _allChanged: Function;
		
		private var _numChanged: int;
		private var _names: Dictionary = new Dictionary();
		private var _amount: Dictionary = new Dictionary();
		
		override public function setUp(): void {
			_sprite = new StageSprite();
			_numChanged = 0;
		}
		
		public function testBasic(): void {
			_sprite.stageAccess.fullScreen;
			assertFalse( _sprite.stageAccess.added.isFalse );
			
			STAGE.addChild( _sprite );
			
			assertTrue( _sprite.stageAccess.added.isTrue );
			
			STAGE.removeChild( _sprite );
			
			assertTrue( _sprite.stageAccess.added.isFalse );
			
			STAGE.scaleMode = StageScaleMode.NO_SCALE;
			STAGE.align = StageAlign.TOP_LEFT;
			
			_props = accessForStage( STAGE );
			expect( "p.mouseX", _props.mouseX, 1 );
			expect( "p.mouseY", _props.mouseY, 1 );
			expect( "p.width", _props.width, 2 );
			expect( "p.height", _props.height, 2 );
			expect( "p.fullscreen", _props.fullScreen, 2 );
			
			trace( "Waiting for mouse to move and stage to resize in the next 10 seconds" );
			
			STAGE.addChild( _sprite );
			expect( "s.mouseX", _sprite.stageAccess.mouseX, 1 );
			expect( "s.mouseY", _sprite.stageAccess.mouseY, 1 );
			expect( "s.width", _sprite.stageAccess.width, 2 );
			expect( "s.height", _sprite.stageAccess.height, 2 );
			expect( "s.fullscreen", _sprite.stageAccess.fullScreen, 2 );
			
			STAGE.addEventListener( MouseEvent.CLICK, toFullScreen );
			
			_allChanged = addAsync( function( e: Event = null ): void {}, 10000, null, function(): void {
				for( var field: * in _names ) {
					trace( _names[field] + " is missing " + _amount[field] + " executions" );
				}
			} );
		}

		private function expect( name: String, field: IField, amount: int ): void {
			_names[ field ] = name;
			_amount[ field ] = amount;
			field.listen( change );
			_numChanged += amount;
		}
		
		private function toFullScreen( event: MouseEvent ): void {
			STAGE.displayState = StageDisplayState.FULL_SCREEN;
		}
		
		private function change( field: IField, oldValue: *, newValue: * ): void {
			_amount[ field ]--;
			trace( "Registered " + _names[field] );
			if( _amount[ field ] == 0 ) {
				field.unlisten( change );
				delete _amount[ field ];
				delete _names[ field ];
			}
			oldValue; newValue;
			_numChanged--;
			if( _numChanged == 0 ) {
				trace( "Done. Thanks!" );
				_allChanged( null );
			}
		}

		override public function tearDown(): void {
			if( _sprite.stage ) {
				STAGE.removeChild( _sprite );
			}
		}

	}
}
