package nanosome.notify.field.expr {
	import flexunit.framework.TestCase;

	import nanosome.notify.field.Field;
	import nanosome.notify.field.expr.value.StaticNumber;

	import flash.system.Capabilities;

	/**
 * @author Martin Heidegger mh@leichtgewicht.at
 */
	public class ExpressionTest extends TestCase {
		public function testSimpleExpressions(): void {
			var ex1 : Expression = expr(null);
			assertStrictlyEquals(ex1, expr(ex1));
			assertEquals( NaN, expr(null).asNumber );
			assertEquals( 1.0, expr(1).asNumber );
			assertEquals( 1.0, expr(StaticNumber.forValue(1)).asNumber);
			assertEquals( 2.0, expr("1+1").asNumber );
			assertEquals( 2.5, expr("1.5+1").asNumber );
			assertEquals( .8, expr("2-1.2").asNumber );
			assertEquals( 3.0, expr("2--1").asNumber );
			assertEquals( -1.0, expr("-2+1").asNumber );
			assertEquals( -2.0, expr("-1-1").asNumber );
			assertEquals( 1.0, expr("1*1").asNumber );
			assertEquals( 3.0, expr("3*1").asNumber );
			assertEquals( -3.0, expr("-3*1").asNumber );
			assertEquals( 6.0, expr("3*2").asNumber );
			assertEquals( -6.0, expr("3*-2").asNumber );
			assertEquals( 1, expr("1/1").asNumber );
			assertEquals( Infinity, expr("1/0").asNumber );
			assertEquals( int.MAX_VALUE, expr("1/0").asInt );
			assertEquals( 1/3, expr("1/3").asNumber );
			assertEquals( -1/3, expr("-1/3").asNumber );
			assertEquals( -1/3, expr("1/-3").asNumber );
			assertEquals( -1/6, expr("1/(-3*2)").asNumber );
			assertEquals( -1/1.5, expr("(1/-3)*2").asNumber );
			
			// These things should parse without a error
			expr( "+1" );
			expr( "(1)" );
			expr( "+1.0" );
			expr( "-1.0" );
			expr( "" );
			expr( "1.0cm" );
			expr( "1%" );
		}
		
		public function testUnits(): void {
			
			assertEquals( 2.56, expr( "1%" ).base( 256 ).asNumber );
			assertEquals( -2.56, expr( "-1%" ).base( 256 ).asNumber );
			assertEquals( 2.5 * 2.56, expr( "-2.5%").base( -256 ).asNumber );
			
			assertEquals( 15.0, expr( "15px" ).asNumber );
			assertEquals( -15.0, expr( "-15px" ).asNumber );
			assertEquals( -15.8, expr( "-15.8px" ).asNumber );
			
			assertEquals( 13.0, expr( "1em" ).asNumber );
			assertEquals( -13.0, expr( "-1em" ).asNumber );
			assertEquals( -19.5, expr( "-1.5em" ).asNumber );
			
			assertEquals( 7.0, expr( "1ex" ).asNumber );
			assertEquals( -7.0, expr( "-1ex" ).asNumber );
			assertEquals( -10.5, expr( "-1.5ex" ).asNumber );
			
			assertEquals( Capabilities.screenDPI,  expr( "1in" ).asNumber );
			assertEquals( Capabilities.screenDPI * (1 / 2.54), expr( "1cm" ).asNumber );
			assertEquals( Capabilities.screenDPI * (1 / 25.4),  expr( "1mm" ).asNumber );
			assertEquals( Capabilities.screenDPI * (1 / 72 * 12),  expr( "1pc" ).asNumber );
			assertEquals( Capabilities.screenDPI * (1 / 72),  expr( "1pt" ).asNumber );
		}
		
		public function testGroups(): void {
			
			assertEquals( 2+3*3, expr( "2+3*3" ).asNumber );
			assertEquals( 2+-3*3, expr( "2+-3*3" ).asNumber );
			assertEquals( 2+(3+5)*3, expr( "2+(3+5)*3" ).asNumber );
			assertEquals( 2+-(3+5)*3, expr( "2+-(3+5)*3" ).asNumber );
			assertEquals( 2*3+3, expr( "2*3+3" ).asNumber );
			assertEquals( (2+3)*3, expr( "(2+3)*3" ).asNumber );
			assertEquals( 2+3+5*3, expr( "2+3+5*3" ).asNumber );
			assertEquals( (2+3+5)*3, expr( "(2+3+5)*3" ).asNumber );
			assertEquals( (2+(3*3)*6), expr( "(2+(3*3)*6)" ).asNumber );
			assertEquals( (2+(3)*3), expr( "(2+(3)*3)" ).asNumber );
			assertEquals( (2*(3)+3), expr( "(2*(3)+3)" ).asNumber );
			assertEquals( (2*(3)/5), expr( "(2*(3)/5)" ).asNumber );
			assertEquals( (2-(3)/5), expr( "(2-(3)/5)" ).asNumber );
			assertEquals( (2/(3)-5), expr( "(2/(3)-5)" ).asNumber );
			assertEquals( (2/(3)-5)+3, expr( "(2/(3)-5)+3" ).asNumber );
			assertEquals( (2/(3)-5)-3, expr( "(2/(3)-5)-3" ).asNumber );
		}
		
		public function testFieldBinding(): void {
			var testField1: Field = new Field();
			var e1: Expression = expr( "{test}" );
			assertEquals( NaN, e1.asNumber );
			assertEquals( NaN, e1.field( "test", testField1 ).asNumber );
			testField1.value = 12;
			assertEquals( 12, e1.asNumber );
		}
		
		public function testParseErrors(): void {
			try {
				expr( "1+" );
				fail( "Parse error should have occured" );
			} catch( e: ExpressionParseError ) {
				assertEquals( 1, e.pos );
				assertEquals( ExpressionParseError.NO_VALUE_FOR_OPERATION, e.type );
			}
			
			try {
				expr( "a" );
				fail( "Parse error should have occured" );
			} catch( e: ExpressionParseError ) {
				assertEquals( 0, e.pos );
				assertEquals( ExpressionParseError.UNEXPECTED_CONSTANT, e.type );
			}
			
			try {
				expr( "cm" );
				fail( "Parse error should have occured" );
			} catch( e: ExpressionParseError ) {
				assertEquals(1, e.pos);
				assertEquals(ExpressionParseError.NO_VALUE_FOR_OPERATION, e.type);
			}
			
			try {
				expr( "1+(2" );
				fail( "Parse error should have occured" );
			} catch( e: ExpressionParseError ) {
				assertEquals(3, e.pos);
				assertEquals(ExpressionParseError.GROUP_NOT_CLOSED, e.type);
			}
			
			try {
				expr( ")1+2" );
				fail( "Parse error should have occured" );
			} catch( e: ExpressionParseError ) {
				assertEquals(0, e.pos);
				assertEquals(ExpressionParseError.GROUP_NOT_OPENED, e.type);
			}
			
			try {
				expr( "(1))+2" );
				fail( "Parse error should have occured" );
			} catch( e: ExpressionParseError ) {
				assertEquals(3, e.pos);
				assertEquals(ExpressionParseError.GROUP_NOT_OPENED, e.type);
			}
			
			try {
				expr( "1}/2" );
				fail( "Parse error should have occured" );
			} catch( e: ExpressionParseError ) {
				assertEquals(1, e.pos);
				assertEquals(ExpressionParseError.EXPRESSION_NOT_OPENED, e.type);
			}
			
			try {
				expr( "{/2" );
				fail( "Parse error should have occured" );
			} catch( e: ExpressionParseError ) {
				assertEquals(2, e.pos);
				assertEquals(ExpressionParseError.EXPRESSION_NOT_CLOSED, e.type);
			}
			
			try {
				expr( "1px 1px" );
				fail( "Parse error should have occured" );
			} catch( e: ExpressionParseError ) {
				assertEquals(ExpressionParseError.OPERATION_NOT_FOUND, e.type);
				assertEquals(6, e.pos);
			}
			
			try {
				expr( "1px 1px" );
				fail( "Parse error should have occured" );
			} catch( e: ExpressionParseError ) {
				assertEquals(ExpressionParseError.OPERATION_NOT_FOUND, e.type);
				assertEquals(6, e.pos);
			}
		}
	}
}
