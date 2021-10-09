// Glyco © 2021 Constantino Tsarouhas

enum Lexeme {
	
	case leadingParenthesis
	case trailingParenthesis
	
	case leadingBrace
	case trailingBrace
	
	case `let`
	case `in`
	case `if`
	case `else`
	
	case isa
	case mapsTo
	case assignedTo
	case equalTo
	case plus
	case minus
	
	case identifier(String)
	
}
