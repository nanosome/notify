package nanosome.notify.bind {
	import flexunit.framework.TestCase;

	import nanosome.notify.field.Field;
	import nanosome.notify.field.IField;
	import nanosome.notify.bind.impl.BINDER;

	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public class BinderTest extends TestCase {
		
		public function testUnbinding(): void {
			var field1: IField = new Field(1);
			var field2: IField = new Field(2);
			
			BINDER.bind( field1, field2 );
			BINDER.unbind( field2 );
			
			assertFalse( field1.hasObserver( BINDER ) );
			assertFalse( field2.hasObserver( BINDER ) );
		}
		
		public function testStaticBinding(): void {
			var field1: IField = new Field(1);
			var field2: IField = new Field(2);
			var staticField1: IField = new StaticField(3);
			var staticField2: IField = new StaticField(4);
			
			BINDER.bind( field1, staticField1 );
			
			assertEquals( 3, field1.value );
			assertEquals( 3, staticField1.value );
			
			field1.value = 5;
			
			assertEquals( 3, field1.value );
			assertEquals( 3, staticField1.value );
			
			assertEquals( field2, BINDER.bind( field2, field1 ) );
			
			assertEquals( 3, field1.value );
			assertEquals( 3, field2.value );
			assertEquals( 3, staticField1.value );
			
			field1.value = 6;
			
			assertEquals( 3, field1.value );
			assertEquals( 3, field2.value );
			assertEquals( 3, staticField1.value );
			
			assertEquals( staticField1, BINDER.unbind( staticField1 ) );
			
			// See if the values eventually changed
			assertEquals( 3, field1.value );
			assertEquals( 3, field2.value );
			assertEquals( 3, staticField1.value );
			
			// Test if the modification now really just applies to the bound
			// mos
			field1.value = 7;
			
			assertEquals( 7, field1.value );
			assertEquals( 7, field2.value );
			assertEquals( 3, staticField1.value );
			
			// Test modification of the second MO as well to see if the relation
			// is still both wise
			field2.value = 8;
			
			assertEquals( 8, field1.value );
			assertEquals( 8, field2.value );
			assertEquals( 3, staticField1.value );
			
			assertEquals( field2, BINDER.bind( field2, staticField2 ) );
			
			// Make sure that adding of another static value to the mo list keeps
			// the thing from throwing off
			assertEquals( 4, field1.value );
			assertEquals( 4, field2.value );
			assertEquals( 4, staticField2.value );
			assertEquals( 3, staticField1.value );
			
			// Make sure a unchangable one can only be once added.
			var errorFound: Boolean = false;
			try {
				BINDER.bind( field1, staticField1 );
			} catch( e: Error ) {
				errorFound = true;
			}
			assertTrue( errorFound );
			
			BINDER.unbind( field1 );
			BINDER.unbind( field2 );
			BINDER.unbind( staticField1 );
			BINDER.unbind( staticField2 );
		}
		
		public function testMoreMastersAndStatics(): void {
			var errorThrown: Boolean  = false;
			var field1: IField = new Field();
			var field2: IField = new Field();
			var field3: IField = new Field();
			var field4: IField = new Field();
			var staticField1: IField = new StaticField( "c" );
			var staticField2: IField = new StaticField( "d" );
			
			BINDER.bind( field1, field2, false );
			BINDER.bind( field3, field4, false );
			
			// Automatically field3 should become master!
			// Because its in circle 1 the master before
			BINDER.bind( field4, field1 );
			
			field1.value = "b";
			field3.value = "a";
			
			assertEquals( "a", field1.value );
			assertEquals( "a", field2.value );
			assertEquals( "a", field3.value );
			assertEquals( "a", field4.value );
			
			BINDER.unbind( field1 );
			BINDER.unbind( field2 );
			
			BINDER.bind( field1, staticField1 );
			
			try {
				BINDER.bind( field1, field3 );
			} catch( e : Error ) {
				errorThrown = true;
			}
			
			assertTrue( errorThrown );
			errorThrown = false;
			assertEquals( "a", field3.value );
			assertEquals( "a", field4.value );
			assertEquals( "c", field1.value);
			
			try {
				BINDER.bind( field3, field1 );
			} catch( e : Error ) {
				errorThrown = true;
			}
			
			assertTrue( errorThrown );
			assertEquals( "a", field3.value );
			assertEquals( "a", field4.value );
			assertEquals( "c", field1.value );
			
			BINDER.unbind( field1 );
			BINDER.unbind( field2 );
			BINDER.unbind( field3 );
			BINDER.unbind( field4 );
			BINDER.unbind( staticField1 );
			BINDER.unbind( staticField2 );
		}
		
		public function testMasterBinding(): void {
			var field1: IField = new Field();
			var field2: IField = new Field();
			var field3: IField = new Field();
			var field4: IField = new Field();
			
			var staticField1: IField = new StaticField( "c" );
			
			BINDER.bind( field1, field2, false );
			
			field1.value = "a";
			assertEquals( "a", field1.value );
			assertEquals( "a", field2.value );
			
			field2.value = "b";
			assertEquals( "a", field1.value );
			assertEquals( "a", field2.value );
			
			var errorThrown: Boolean = false;
			try {
				BINDER.bind( field2, staticField1 );
			} catch( e: Error ) {
				errorThrown = true;
			}
			assertTrue( "Binding a static field to the a binding with master fields", errorThrown );
			
			// Due to some side effect it could be possible that the value of 
			// the static field (7 lines above) could have been taken
			assertEquals( "a", field1.value );
			assertEquals( "a", field2.value );
			assertEquals( "c", staticField1.value );
			// Also new changes might affect the list
			field1.value = "d";
			assertEquals( "d", field1.value );
			assertEquals( "d", field2.value );
			assertEquals( "c", staticField1.value );
			
			BINDER.bind( field3, staticField1 );
			
			errorThrown = false;
			try {
				BINDER.bind( field4, field3, false );
			} catch( e: Error ) {
				errorThrown = true;
			}
			
			assertTrue( "Binding a master field to a already bound static field", errorThrown );
			
			BINDER.unbind( field3 );
			
			// Just to make sure removing worked properly.
			BINDER.bind( field4, field3, false );
			
			BINDER.unbind( field1 );
			BINDER.unbind( field2 );
			BINDER.unbind( field3 );
			BINDER.unbind( field4 );
			BINDER.unbind( staticField1 );
		}
		
		public function testBasicBinding(): void {
			
			var field1: IField = new Field(1);
			var field2: IField = new Field(2);
			var field3: IField = new Field(3);
			var field4: IField = new Field(4);
			
			assertEquals(field1, BINDER.unbind( field1 ) );
			
			assertEquals( field1, BINDER.bind( field1, field2 ) );
			assertEquals( 1, field2.value );
			assertEquals( 1, field1.value );
			
			assertEquals( field2, BINDER.bind( field2, field3 ) );
			assertEquals( 1, field3.value );
			assertEquals( 1, field2.value );
			assertEquals( 1, field1.value );
			
			assertTrue( field3.setValue( "a" ) );
			assertEquals( "a", field3.value );
			assertEquals( "a", field2.value );
			assertEquals( "a", field1.value );
			
			assertEquals( field2, BINDER.unbind( field2 ) );
			field2.value = "b";
			field1.value = "c";
			assertEquals( "c", field3.value );
			assertEquals( "b", field2.value );
			assertEquals( "c", field1.value );
			
			assertEquals( field2, BINDER.bind( field2, field4 ) );
			assertEquals( "b", field4.value );
			assertEquals( "b", field2.value );
			
			assertEquals( field2, BINDER.bind( field2, field1 ) );
			assertEquals( "b", field4.value );
			assertEquals( "b", field3.value );
			assertEquals( "b", field2.value );
			assertEquals( "b", field1.value );
			
			field4.value = "d";
			assertEquals( "d", field4.value );
			assertEquals( "d", field3.value );
			assertEquals( "d", field2.value );
			assertEquals( "d", field1.value );
			
			assertEquals( field2, BINDER.unbind( field2 ) );
			field4.value = "e";
			assertEquals( "e", field4.value );
			assertEquals( "e", field3.value );
			assertEquals( "d", field2.value );
			assertEquals( "e", field1.value );
			
			assertEquals( field4, BINDER.unbind( field4 ) );
			field3.value = "f";
			assertEquals( "e", field4.value );
			assertEquals( "f", field3.value );
			assertEquals( "d", field2.value );
			assertEquals( "f", field1.value );
			
			assertEquals( field1, BINDER.unbind( field1 ) );
			field3.value = "g";
			assertEquals( "e", field4.value );
			assertEquals( "g", field3.value );
			assertEquals( "d", field2.value );
			assertEquals( "f", field1.value );
			
			// should not throw a exception or something
			assertEquals( field3, BINDER.unbind( field3 ) );
			
			// Normal null binding
			assertEquals( field1, BINDER.bind( field1, null ) );
			assertNull( BINDER.bind( null, field1 ) );
			assertNull( BINDER.bind( null, null ) );
			
			// Null binding with a already exisiting binding
			assertEquals( field1, BINDER.bind( field1, field2 ) );
			assertEquals( field1, BINDER.bind( field1, null ) );
			
			BINDER.unbind( field1 );
			BINDER.unbind( field2 );
			BINDER.unbind( field3 );
			BINDER.unbind( field4 );
		}
	}
}
import nanosome.notify.field.Field;

class StaticField extends Field {
	public function StaticField( value: * ) {
		super( value );
	}
	
	override public function get isChangeable() : Boolean {
		return false;
	}

}