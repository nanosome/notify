package nanosome.notify.bind {
	import flexunit.framework.TestCase;
	import nanosome.util.access.qname;


	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public class TestPath extends TestCase {
		
		public function testDocExamples(): void {
			
			var list: Array = [qname("a"), qname("b"), qname("c")];
			assertArrayEquals( list, path("a", "b", "c") );
			assertArrayEquals( list, path("a.b.c") );
			assertArrayEquals( [qname("foo.bar::a"), qname("b"), qname("c")], path("foo.bar::a", "b", "c") );
			assertArrayEquals( [qname("foo.bar::a"), qname("b"), qname("c")], path("foo.bar::a.b", "c") );
			assertArrayEquals( list, path("a.b", qname("c")) );
		}

		private function assertArrayEquals( arrA: Array, arrB: Array ): void {
			if( arrA.length != arrB.length ) {
				fail( "Arrays don't match in length: "+arrA.length+"!="+arrB.length );
			}
			const l: int = arrA.length;
			for( var i: int = 0; i<l; ++i ){
				if( arrA[i] != arrB[i] ) {
					fail( "At Least item "+i+" doesn't match: " + arrA[i] + "!=" +arrB[i] );
				}
			}
		}
	}
}
namespace ns = "foo.bar";