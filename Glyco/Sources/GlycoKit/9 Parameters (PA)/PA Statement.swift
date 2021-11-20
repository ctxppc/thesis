// Glyco © 2021 Constantino Tsarouhas

import Foundation

extension PA {
	
	/// A description of an action.
	public enum Statement : Codable, Equatable, SimplyLowerable {
		
		/// A statement that computes `value` and puts it in `destination`.
		case assign(destination: Location, value: Expression)
		
		/// A statement that performs `statements`.
		case compound(statements: [Statement])
		
		/// A statement that performs `affirmative` if `predicate` holds, or `negative` otherwise.
		indirect case conditional(predicate: Predicate, affirmative: Statement, negative: Statement)
		
		/// A statement that invokes the procedure named `procedure` with its parameters assigned to `arguments`.
		case invoke(procedureName: Label, arguments: [Expression])
		
		/// A statement that terminates the program with `result`.
		case `return`(result: Expression)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Statement {
			switch self {
				
				case .assign(destination: let destination, value: let value):
				return .assign(destination: destination, value: value)
				
				case .compound(statements: let statements):
				return .compound(statements: try statements.lowered(in: &context))
				
				case .conditional(predicate: let predicate, affirmative: let affirmative, negative: let negative):
				return try .conditional(
					predicate:		predicate,
					affirmative:	affirmative.lowered(in: &context),
					negative:		negative.lowered(in: &context)
				)
				
				case .invoke(procedureName: let name, arguments: let arguments):
				guard let procedure = context.procedures.first(where: { $0.name == name }) else { throw LoweringError.unrecognisedProcedure(name: name) }
				let assignments = procedure.parameterAssignments()
				return .compound(
					statements:	zip(assignments, arguments).reversed().map { $0.0.physicalLocation <- $0.1 }
				)	// assign register parameters last to keep those register's liveness as short as possible
				
				case .return(result: let result):
				return .return(result: result)
				
			}
		}
		
		enum LoweringError : LocalizedError {
			
			/// An error indicating that no procedure is known by the name `name`.
			case unrecognisedProcedure(name: Label)
			
			// See protocol.
			var errorDescription: String? {
				switch self {
					case .unrecognisedProcedure(name: let name):	return "No procedure known by the name “\(name)”"
				}
			}
			
		}
		
	}
	
}

public func <- (destination: PA.Location, source: PA.Expression) -> PA.Statement {
	.assign(destination: destination, value: source)
}
