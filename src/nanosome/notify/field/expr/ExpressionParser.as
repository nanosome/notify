package nanosome.notify.field.expr {
	import nanosome.notify.field.expr.operator.ADD;
	import nanosome.notify.field.expr.operator.DIVIDE;
	import nanosome.notify.field.expr.operator.IOperator;
	import nanosome.notify.field.expr.operator.MULTIPLY;
	import nanosome.notify.field.expr.operator.SUBSTRACT;
	import nanosome.notify.field.expr.value.Field;
	import nanosome.notify.field.expr.value.FontSize;
	import nanosome.notify.field.expr.value.IValue;
	import nanosome.notify.field.expr.value.Operation;
	import nanosome.notify.field.expr.value.Percent;
	import nanosome.notify.field.expr.value.ResolutionDependent;
	import nanosome.notify.field.expr.value.StaticNumber;
	import nanosome.notify.field.expr.value.XSize;
	/**
	 * @author mh
	 */
	public class ExpressionParser {
		
		public static const INSTANCE : ExpressionParser = new ExpressionParser();
		
		private static const DPI : Object = {
			"cm": 1.0 / 2.54,
			"mm": 1.0 / 25.4,
			"pt": 1.0 / 72.0,
			"pc": 1.0 / 72.0 * 12.0,
			"in": 1.0
		};
		
		private const INVALID_CONST_CHARS: Object = {
			"+": true,
			"-": true,
			"*": true,
			"%": true,
			"/": true,
			"(": true,
			"{": true,
			"}": true,
			" ": true,
			"\n": true,
			"\t": true
		};
		
		private var _numberCache : String;
		private var _expressionCache : String;
		private var _position : int;
		private var _inputString : String;
		private var _operationStack: Array;
		private var _rootOperation: Operation;
		private var _currentOperation: Operation;
		private var _minusStack: Array;
		private var _constantCache: String;
		
		public function ExpressionParser() {
			super();
		}
		
		public function parse( value: * ): IValue {
			if( value is IValue ) {
				return value;
			}
			else
			if( value is String ) {
				var string: String = value;
				const l: int = string.length;
				
				if( /^[ \t\n]*$/.test( string ) ) {
					return null;
				}
				
				_inputString = string;
				_position = 0;
				_rootOperation = new Operation();
				_numberCache = "";
				_constantCache = null;
				_expressionCache = null;
				
				_operationStack = [ _rootOperation ];
				_minusStack = [ false ];
				_currentOperation = _rootOperation;
				
				while( _position < l ) {
					var chr: String = string.charAt(_position);
					if( null != _constantCache ) {
						if( INVALID_CONST_CHARS[chr] ) {
							endConstant();
							continue;
						} else {
							_constantCache += chr;
						}
					}
					else
					if( null != _expressionCache ) {
						switch( chr ) {
							case "}":
								endExpression();
								break;
							default:
								_expressionCache += chr;
						}
					} else {
						switch( chr ) {
							case "-":
								treatMinus();
								break;
							case "+":
								treatLineOp(ADD);
								break;
							case "/":
								setOperator(DIVIDE);
								break;
							case "*":
								setOperator(MULTIPLY);
								break;
							case "%":
								toPercentValue();
								break;
							case "(":
								startGroup();
								break;
							case ")":
								endGroup();
								break;
							case "{":
								startExpression();
								break;
							case "}":
								endExpression();
								break;
							case " ":
							case "\t":
							case "\n":
								// white spaces
								break;
							case "1":
							case "2":
							case "3":
							case "4":
							case "5":
							case "6":
							case "7":
							case "8":
							case "9":
							case "0":
							case ".":
								addChar( chr );
								break;
							default:
								startConstant( chr );
						}
					}
					++_position;
				}
				--_position;
				if( _operationStack.length != 1 ) {
					error( ExpressionParseError.GROUP_NOT_CLOSED );
				}
				if( _constantCache ) {
					endConstant();
				}
				finishValue();
				if( _expressionCache ) {
					error( ExpressionParseError.EXPRESSION_NOT_CLOSED );
				}
				if( !_currentOperation.a ) {
					error( ExpressionParseError.NO_VALUE_FOR_OPERATION );
				}
				return reduceTree(_rootOperation );
			} else if( value is Number ) {
				return StaticNumber.forValue( value );
			} else {
				return null;
			}
		}
		
		private function endConstant() : void {
			if( _expressionCache ) {
				error( ExpressionParseError.EXPRESSION_NOT_CLOSED );
			} else {
				if( _constantCache == "px") {
					addValue( StaticNumber.forValue( useNumber() ) );
					_constantCache = null;
				} else if( _constantCache == "em" ) {
					addValue( new FontSize( useNumber() ) );
					_constantCache = null;
				} else if( _constantCache == "ex" ) {
					addValue( new XSize( useNumber() ) );
					_constantCache = null;
				} else {
					var dpi: Number = DPI[ _constantCache ];
					if( dpi > 0 ) {
						addValue( new ResolutionDependent( useNumber() * dpi ) );
						_constantCache = null;
					} else {
						error( ExpressionParseError.UNEXPECTED_CONSTANT );
					}
				}
			}
		}
		
		private function startConstant(chr : String) : void {
			_constantCache = chr;
		}

		private function treatMinus() : void {
			if( !treatLineOp(SUBSTRACT) ) {
				_minusStack[ _minusStack.length-1 ] = true;
			}
		}
		
		private function treatLineOp( operator: IOperator ): Boolean {
			if( _numberCache != "" || _expressionCache || ( _currentOperation.a && !_currentOperation.operator ) ) {
				setOperator(operator);
				var newOp: Operation = new Operation();
				_currentOperation.b = newOp;
				_currentOperation = newOp;
				return true;
			} else {
				return false;
			}
		}
		
		private function reduceTree( value: IValue ) : IValue {
			if( value is Operation ) {
				var op: Operation = Operation( value );
				if( !op.operator ) {
					if( op.a && !op.b ) {
						return reduceTree( op.a );
					}
					throw new Error( "Internal parser error." );
				}
				else
				{
					if( !op.b ) {
						error( ExpressionParseError.NO_VALUE_FOR_OPERATION );
					}
					else
					{
						var operator: IOperator = operator;
						op.a = reduceTree( op.a );
						op.b = reduceTree( op.b );
						
						if( op.a == StaticNumber.NAN || op.b == StaticNumber.NAN ) {
							return StaticNumber.NAN;
						}
						if( op.a == StaticNumber.INFINITY || op.b == StaticNumber.INFINITY ) {
							return StaticNumber.INFINITY;
						}
						if( op.a is StaticNumber && op.b is StaticNumber ) {
							return StaticNumber.forValue( op.getValue() );
						}
						if( operator == ADD || operator == SUBSTRACT ) {
							if( op.a == StaticNumber.ZERO) {
								return op.b;
							} else if( op.b == StaticNumber.ZERO ) {
								return op.a;
							}
						} else if( operator == MULTIPLY || operator == DIVIDE ) {
							if( op.b == StaticNumber.ONE ) {
								return op.a;
							} else if( op.a == StaticNumber.ONE && operator == MULTIPLY ) {
								return op.b;
							}
						}
						operator = op.operator;
						if( op.b is StaticNumber ) {
							if( op.a is Operation ) {
								var opChild: Operation = Operation(op.a);
								if( operator == MULTIPLY ) {
									if( opChild.operator == MULTIPLY ) {
										if( opChild.a is StaticNumber ) {
											op.a = opChild.b;
											op.b = StaticNumber.forValue( MULTIPLY.operate( opChild.a.getValue(), op.b.getValue() ) );
										} else if( opChild.b is StaticNumber ) {
											op.a = opChild.a;
											op.b = StaticNumber.forValue( MULTIPLY.operate( opChild.b.getValue(), op.b.getValue() ) );
										}
									}
									else
									if( opChild.operator == DIVIDE ) {
										if( opChild.a is StaticNumber ) {
											op.a = StaticNumber.forValue( DIVIDE.operate( opChild.a.getValue(), op.b.getValue() ) );
											op.operator = DIVIDE;
											op.b = opChild.b;
										} else if( opChild.b is StaticNumber ) {
											op.a = opChild.a;
											op.b = StaticNumber.forValue( DIVIDE.operate( op.b.getValue(), opChild.b.getValue() ) );
										}
									}
								}
								else
								if( operator == DIVIDE ) {
									if( opChild.operator == MULTIPLY ) {
										if( opChild.a is StaticNumber ) {
											op.a = opChild.b;
											op.operator = MULTIPLY;
											op.b = StaticNumber.forValue( MULTIPLY.operate( opChild.a.getValue(), op.b.getValue() ) );
										} else if( opChild.b is StaticNumber ) {
											op.a = opChild.a;
											op.operator = MULTIPLY;
											op.b = StaticNumber.forValue( MULTIPLY.operate( opChild.b.getValue(), op.b.getValue() ) );
										}
									}
									else
									if( opChild.operator == DIVIDE ) {
										if( opChild.a is StaticNumber ) {
											op.a = StaticNumber.forValue( DIVIDE.operate( opChild.a.getValue(), op.b.getValue() ) );
											op.operator = DIVIDE;
											op.b = opChild.b;
										} else if( opChild.b is StaticNumber ) {
											op.a = opChild.a;
											op.operator = DIVIDE;
											op.b = StaticNumber.forValue( MULTIPLY.operate( opChild.b.getValue(), op.b.getValue() ) );
										}
									}
								}
							}
						}
						return op;
					}
				}
			}
			return value;
		}
		
		private function addChar( chr: String ): void {
			_numberCache += chr;
		}
		
		private function endExpression() : void {
			if( !_expressionCache ) {
				error( ExpressionParseError.EXPRESSION_NOT_OPENED );
			}
			addValue( new Field( _expressionCache ) );
			_expressionCache = null;
		}
		
		private function startExpression() : void {
			finishValue();
			if( _expressionCache ) {
				error( ExpressionParseError.EXPRESSION_NOT_CLOSED );
			}
			_expressionCache = "";
		}

		private function endGroup() : void {
			finishValue();
			if( _operationStack.length > 1 ) {
				_minusStack.pop();
				_operationStack.pop();
				_currentOperation = _operationStack[ _operationStack.length-1 ];
			} else {
				error( ExpressionParseError.GROUP_NOT_OPENED );
			}
		}
		
		private function addValue( value: IValue ) : void {
			if( _minusStack[ _minusStack.length-1 ]  ) {
				var op: Operation = new Operation();
				op.a = StaticNumber.MINUS_ONE;
				op.operator = MULTIPLY;
				op.b = value;
				value = op;
				_minusStack[ _minusStack.length-1 ] = false;
			}
			if( _currentOperation.a ) {
				if( !_currentOperation.operator ) {
					error( ExpressionParseError.OPERATION_NOT_FOUND );
				}
				var newOperation: Operation = new Operation();
				newOperation.a = _currentOperation.a;
				newOperation.b = value;
				newOperation.operator = _currentOperation.operator;
				_currentOperation.a = newOperation;
				_currentOperation.operator = null;
				_currentOperation.b = null;
			} else {
				_currentOperation.a = value;
			}
		}
		
		private function startGroup(): void {
			var group: Operation = new Operation();
			addValue( group );
			_operationStack.push(group);
			_minusStack.push(false);
			_currentOperation = group;
		}
		
		private function toPercentValue() : void {
			addValue( new Percent( useNumber() / 100 ) );
			
			if( _expressionCache ) {
				error( ExpressionParseError.EXPRESSION_NOT_CLOSED );
			}
		}
		
		private function useNumber(): Number {
			if( _numberCache.length > 0 ) {
			{
				var num: Number = (_minusStack[ _minusStack.length-1 ] ? -1.0 : 1.0 ) * parseFloat( _numberCache );
				_numberCache = "";
				_minusStack[ _minusStack.length-1 ] = false;
				return num;
			}
			}
			else {
				error( ExpressionParseError.NO_VALUE_FOR_OPERATION );
				// This is just to satisfy the compiler ...
				return NaN;
			}
		}

		private function setOperator( operator: IOperator ): void {
			finishValue();
			
			if( !_currentOperation.a ) {
				error( ExpressionParseError.NO_VALUE_FOR_OPERATION );
			}
			else
			if( _currentOperation.b ) {
				var newOperation: Operation = new Operation();
				newOperation.a = _currentOperation.b;
				_currentOperation.b = newOperation;
				_currentOperation = newOperation;
			}
			else
			if( _currentOperation.operator ) {
				error( ExpressionParseError.NO_VALUE_FOR_OPERATION );
			}
			_currentOperation.operator = operator;
		}
		
		private function finishValue() : void {
			if( _expressionCache ) {
				error( ExpressionParseError.EXPRESSION_NOT_CLOSED );
			}
			try {
				addValue( StaticNumber.forValue( useNumber() ) );
			} catch( e: ExpressionParseError ) {}
		}
		
		private function error(type : String): void {
			throw new ExpressionParseError( type, _position, _inputString );
		}
	}
}
