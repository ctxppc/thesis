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
		
		/// A statement that invokes the procedure named `procedure` passing `arguments` as arguments to it.
		case invoke(procedure: Label, arguments: [Expression])
		
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
				
				case .invoke(procedure: let procedure, arguments: let arguments):
				var loweredArguments = [Lower.Source]()
				var copyEffects = [Lower.Effect]()
				for argument in arguments {
					switch argument {
						
						case .constant(value: let value):
						loweredArguments.append(.immediate(value))
						
						case .location(location: let location):
						loweredArguments.append(.location(location))
						
						default:
						let temporary = context.allocateLocation()
						loweredArguments.append(.location(temporary))
						copyEffects.append(argument.lowered(destination: temporary, context: &context))
						
					}
				}
				return .sequence(effects: copyEffects + [.invoke(procedure: procedure, arguments: loweredArguments)])
				
				case .return(result: .constant(value: let value)):
				return .return(result: .immediate(value))
				
				case .return(result: .location(location: let location)):
				return .return(result: .location(location))
				
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
