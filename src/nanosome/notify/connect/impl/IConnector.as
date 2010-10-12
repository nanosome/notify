package nanosome.notify.connect.impl {
	import nanosome.util.IDisposable;
	/**
 * @author Martin Heidegger mh@leichtgewicht.at
 */
	internal interface IConnector extends IDisposable {
		function init( source: Object, target: Object, map: MapInformation ): IConnector;
		function get weak(): Boolean;
		function get onEnterFrame(): Boolean;
		function set onEnterFrame( update: Boolean ): void;
	}
}
