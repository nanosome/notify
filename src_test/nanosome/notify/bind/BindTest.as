package nanosome.notify.bind {
	import nanosome.notify.bind.bind;
	import org.mockito.integrations.flexunit3.MockitoTestCase;

	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public class BindTest extends MockitoTestCase {
		
		private var _obj1 : Object;
		private var _obj2 : Object;
		
		public function BindTest(mockClasses : Array) {
			super(mockClasses);
		}
		
		public function testBinding(): void {
			
			_obj1 = {};
			_obj2 = {};
			
			bind( _obj1, "honny.moon", _obj2, "cat.food" );
			
			_obj1.honny = { moon: "hello" };
			
			// Direct binding not possible on enterframe
			assertNull( _obj2.cat );
		}
	}
}
