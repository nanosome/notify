// @license@ 
package nanosome.notify.field.stage {
	
	import flash.display.Stage;
	
	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public function accessForStage( stage: Stage ): StageAccess {
		return _registry[ stage ] || ( _registry[ stage ] = new StageAccess( stage ) );
	}
}

import flash.utils.Dictionary;

const _registry: Dictionary = new Dictionary( true );
