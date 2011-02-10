// @license@ 
package nanosome.notify.field.expr {

	/**
	 * @author mh
	 */
	public class ExpressionParseError extends Error {
		
		public static const EXPRESSION_NOT_CLOSED: String = "The expression has not been closed.";
		public static const NO_VALUE_FOR_OPERATION: String = "No value to operate at.";
		public static const GROUP_NOT_OPENED: String = "No matching opening brace.";
		public static const EXPRESSION_NOT_OPENED: String = "Unexpected expression end.";
		public static const UNEXPECTED_CHARACTER: String = "Unexpected character.";
		public static const GROUP_NOT_CLOSED: String = "Group not closed.";
		public static const UNEXPECTED_CONSTANT: String = "Unknown Constant. Known Constants are cm,mm,pt,pc,in,em,ex,px" ;
		public static const OPERATION_NOT_FOUND: String = "Operation not found.";

		private var _type: String;
		private var _pos: int;
		private var _expression: String;

		public function ExpressionParseError( type: String, pos: int, expression: String ) {
			_expression = expression;
			_pos = pos;
			_type = type;
		}
		
		public function get type(): String {
			return _type;
		}
		
		public function get pos(): int {
			return _pos;
		}
		
		public function get expression(): String {
			return _expression;
		}
		
		public function toString() : String {
			var spaces: String = createSpaces( pos );
			return "Expression could not be parsed: " + _type + "\n  " + spaces + "!\n  " + _expression.replace( /\n/, "\\" ) + "\n  " + spaces + "^";
		}

		private function createSpaces( pos: int ) : String {
			var result: String = "";
			pos -= 4;
			while( pos > 0 ) {
				result += " ";
			}
			return result;
		}
	}
}
