// Glyco © 2021–2022 Constantino Tsarouhas

extension EX {
	
	/// A program element describing how to retrieve or compute a value for use in a statement or other expression.
	public enum Expression : Codable, Equatable {
		
		/// An expression evaluating to a value.
		case constant(Int)
		
		/// An expression evaluating to the value in given location
		case location(Location)
		
		/// An expression evaluating a binary operation between two expressions.
		indirect case binary(Expression, BinaryOperator, Expression)
		
		/// An expression evaluating to `then` if the predicate holds or to `else` otherwise.
		indirect case `if`(Predicate, then: Expression, else: Expression)
		
		/// Returns an effect that computes or retrieves the value described by `self` and puts it in `destination`.
		func lowered(destination: Lower.Location, context: inout Context) -> Lower.Effect {
			switch self {
				
				case .constant(value: let value):
				return .set(destination, to: .immediate(value))
				
				case .location(location: let location):
				return .set(destination, to: .location(location))
				
				case .binary(.constant(value: let first), let op, .constant(value: let second)):
				return .compute(.immediate(first), op, .immediate(second), to: destination)
				
				case .binary(.constant(value: let first), let op, .location(location: let second)):
				return .compute(.immediate(first), op, .location(second), to: destination)
				
				case .binary(.location(location: let first), let op, .constant(value: let second)):
				return .compute(.location(first), op, .immediate(second), to: destination)
				
				case .binary(.location(location: let first), let op, .location(location: let second)):
				return .compute(.location(first), op, .location(second), to: destination)
				
				case .binary(let first, let op, let second):
				let firstLocation = context.allocateLocation()
				let secondLocation = context.allocateLocation()
				return .do([
					first.lowered(destination: firstLocation, context: &context),
					second.lowered(destination: secondLocation, context: &context),
					Self.binary(.location(firstLocation), op, .location(secondLocation))
						.lowered(destination: destination, context: &context)
				])
				
				case .if(let predicate, then: let affirmative, else: let negative):
				return predicate.lowered(
					in:				&context,
					affirmative:	affirmative.lowered(destination: destination, context: &context),
					negative:		negative.lowered(destination: destination, context: &context)
				)
				
			}
		}
		
	}
	
	
}
