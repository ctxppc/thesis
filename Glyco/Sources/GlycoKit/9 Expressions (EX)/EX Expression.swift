// Glyco © 2021 Constantino Tsarouhas

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
				return .copy(destination: destination, source: .immediate(value))
				
				case .location(location: let location):
				return .copy(destination: destination, source: .location(location))
				
				case .binary(.constant(value: let first), let op, .constant(value: let second)):
				return .compute(destination: destination, .immediate(first), op, .immediate(second))
				
				case .binary(.constant(value: let first), let op, .location(location: let second)):
				return .compute(destination: destination, .immediate(first), op, .location(second))
				
				case .binary(.location(location: let first), let op, .constant(value: let second)):
				return .compute(destination: destination, .location(first), op, .immediate(second))
				
				case .binary(.location(location: let first), let op, .location(location: let second)):
				return .compute(destination: destination, .location(first), op, .location(second))
				
				case .binary(let first, let op, let second):
				let firstLocation = context.allocateLocation()
				let secondLocation = context.allocateLocation()
				return .sequence([
					first.lowered(destination: firstLocation, context: &context),
					second.lowered(destination: secondLocation, context: &context),
					Self.binary(.location(firstLocation), op, .location(secondLocation))
						.lowered(destination: destination, context: &context)
				])
				
				case .if(let predicate, then: let affirmative, else: let negative):
				return .if(
					predicate,
					then:	affirmative.lowered(destination: destination, context: &context),
					else:	negative.lowered(destination: destination, context: &context)
				)
				
			}
		}
		
	}
	
	public typealias BinaryOperator = Lower.BinaryOperator
	
}
