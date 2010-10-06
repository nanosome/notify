package nanosome.notify.bind.map {
	import nanosome.util.access.Accessor;

	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public interface IClassMapping {
		
		function get inverted(): IClassMapping;
		
		function get source(): Accessor;
		
		function get target(): Accessor;
		
		function get propertyMap(): Object;
		
		function get isEntirelyDynamic(): Boolean;
	}
}
