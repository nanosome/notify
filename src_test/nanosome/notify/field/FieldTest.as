package nanosome.notify.field {
	
	
	import nanosome.notify.field.Field;

	import org.mockito.integrations.eq;
	import org.mockito.integrations.flexunit3.MockitoTestCase;
	import org.mockito.integrations.inOrder;
	import org.mockito.integrations.mock;

	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public class FieldTest extends MockitoTestCase {
		
		public function FieldTest( mocks: Array = null ) {
			super( flatAndClean( [IFieldObserver].concat(mocks) ));
		}
		
		private function flatAndClean( arr: Array ) : Array {
			var i: int = arr.length;
			while( --i > -1 ) {
				var val: * = arr[i];
				if( !val ) {
					arr.splice(i,1);
				} else {
					if( val is Array ) {
						val = flatAndClean( arr );
						arr.splice(i,1,val);
					}
				}
			}
			return arr;
		}
		
		public function testObservers(): void {
			var field: IField = getMO();
			
			var observer: IFieldObserver = mock( IFieldObserver );
			
			assertTrue( field.addObserver( observer ) );
			assertTrue( field.hasObserver( observer ) );
			assertFalse( field.addObserver( observer ) );
			assertTrue( field.hasObserver( observer ) );
			assertTrue( field.removeObserver( observer ) );
			assertFalse( field.hasObserver( observer ) );
			assertFalse( field.removeObserver( observer ) );
			assertFalse( field.hasObserver( observer ) );
			
			field.addObserver( observer );
			
			var doContinue: Boolean = true;
			if( field.isChangeable ) {
				var formerValue: * = field.value;
				field.value = null;
				inOrder().verify().that( observer.onFieldChange( eq(field), eq(formerValue), eq(null) ) );
				assertNull( field.value );
				field.value = formerValue;
				inOrder().verify().that( observer.onFieldChange( eq(field), eq(null), eq(formerValue) ) );
				assertEquals( formerValue, field.value );
				
			} else {
				// In case the mo ain't changable then assume exceptions will be thrown.
				try {
					field.value = null;
				} catch( e: * ) {
					assertEquals( formerValue, field.value );
					doContinue = false;
				}
				assertFalse( doContinue );
				doContinue = true;
				try {
					field.value = {};
				} catch( e: * ) {
					assertEquals( formerValue, field.value );
					doContinue = false;
				}
				assertFalse( doContinue );
			}
			
			// End verification
			observer.onFieldChange( null, null, null );
			inOrder().verify().that( observer.onFieldChange( eq( null ), eq( null ), eq( null ) ));
		}
		
		protected function getMO() : IField {
			return new Field({});
		}
	}
}
import nanosome.notify.field.IFieldObserver;
import nanosome.notify.field.IField;

import org.flexunit.asserts.assertEquals;

class TestObserver implements IFieldObserver {
	
	public function onFieldChange(mo : IField, oldValue : * = null, newValue : * = null) : void {
		assertEquals( mo.value, newValue );
	}
}