// @license@ 
package nanosome.notify.field.stage {
	
	import flash.display.Stage;
	
	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	internal function broadcasterForStage( stage: Stage ): StageChangeBroadcaster {
		return _registry[ stage ] || ( _registry[ stage ] = new StageChangeBroadcaster( stage ) );
	}
}

import flash.utils.Dictionary;

const _registry: Dictionary = new Dictionary( true );
