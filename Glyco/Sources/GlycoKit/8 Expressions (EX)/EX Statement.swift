// Glyco © 2021 Constantino Tsarouhas

extension EX {
	
	/// A description of an action.
	public enum Statement : Codable, Equatable, SimplyLowerable {
		
		/// A statement that computes `value` and puts it in `destination`.
		case assign(destination: Location, value: Expression)
		
		/// A statement that performs `statements`.
		case compound(statements: [Statement])
		
		/// A statement that performs `affirmative` if `predicate` holds, or `negative` otherwise.
		indirect case conditional(predicate: Predicate, affirmative: Statement, negative: Statement)
		
		/// A statement that terminates the program with `result`.
		case `return`(result: Expression)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Effect {
			switch self {
				
				case .assign(destination: let destination, value: let value):
				return value.lowered(destination: destination, context: &context)
				
				case .compound(statements: let statements):
				return .sequence(effects: try statements.lowered(in: &context))
				
				case .conditional(predicate: let predicate, affirmative: let affirmative, negative: let negative):
				return .conditional(
					predicate:		predicate,
					affirmative:	try affirmative.lowered(in: &context),
					negative:		try negative.lowered(in: &context)
				)
				
				case .return(result: let result):
				let resultLocation = context.allocateLocation()
				return .sequence(effects: [
					result.lowered(destination: resultLocation, context: &context),
					.return(result: .location(resultLocation)),
				])
				
			}
		}
		
	}
	
}

public func <- (destination: EX.Location, source: EX.Expression) -> EX.Statement {
	.assign(destination: destination, value: source)
}
