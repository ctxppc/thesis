// Glyco © 2021–2022 Constantino Tsarouhas

extension EX {
	
	/// A description of an action.
	public enum Statement : Codable, Equatable, SimplyLowerable {
		
		/// A statement that assigns given location the value evaluated by given expression.
		case assign(Location, value: Expression)
		
		/// A statement that a sequence of statements.
		case sequence([Statement] = [])
		
		/// A statement that performs `then` if the predicate holds, or `else` otherwise.
		indirect case `if`(Predicate, then: Statement, else: Statement = .sequence())
		
		/// A statement that invokes the named procedure with given arguments.
		case invoke(Label, [Expression])
		
		/// A statement that terminates the program with a result value.
		case `return`(Expression)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Effect {
			switch self {
				
				case .assign(let destination, value: let value):
				return value.lowered(destination: destination, context: &context)
				
				case .sequence(let statements):
				return .sequence(try statements.lowered(in: &context))
				
				case .if(let predicate, then: let affirmative, else: let negative):
				return try predicate.lowered(in: &context, affirmative: affirmative.lowered(in: &context), negative: negative.lowered(in: &context))
				
				case .invoke(let procedure, let arguments):
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
				return .sequence(copyEffects + [.invoke(procedure, loweredArguments)])
				
				case .return(result: .constant(value: let value)):
				return .return(.immediate(value))
				
				case .return(result: .location(location: let location)):
				return .return(.location(location))
				
				case .return(result: let result):
				let resultLocation = context.allocateLocation()
				return .sequence([
					result.lowered(destination: resultLocation, context: &context),
					.return(.location(resultLocation)),
				])
				
			}
		}
		
	}
	
}

public func <- (destination: EX.Location, source: EX.Expression) -> EX.Statement {
	.assign(destination, value: source)
}
