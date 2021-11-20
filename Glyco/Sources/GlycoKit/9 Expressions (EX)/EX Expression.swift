// Glyco © 2021 Constantino Tsarouhas

extension EX {
	
	/// A program element describing how to retrieve or compute a value for use in a statement or other expression.
	public enum Expression : Codable, Equatable {
		
		/// An expression evaluating to `value`.
		case constant(value: Int)
		
		/// An expression evaluating to the value in `location`.
		case location(location: Location)
		
		/// An expression evaluating to `first` `op` `second`.
		indirect case binary(first: Expression, op: BinaryOperator, second: Expression)
		
		/// An expression evaluating to `affirmative` if `predicate` holds or to `negative` otherwise.
		indirect case conditional(predicate: Predicate, affirmative: Expression, negative: Expression)
		
		/// Returns an effect that computes or retrieves the value described by `self` and puts it in `destination`.
		func lowered(destination: Lower.Location, context: inout Context) -> Lower.Effect {
			switch self {
				
				case .constant(value: let value):
				return .copy(destination: destination, source: .immediate(value))
				
				case .location(location: let location):
				return .copy(destination: destination, source: .location(location))
				
				case .binary(first: .constant(value: let first), op: let op, second: .constant(value: let second)):
				return .compute(destination: destination, lhs: .immediate(first), operation: op, rhs: .immediate(second))
				
				case .binary(first: .constant(value: let first), op: let op, second: .location(location: let second)):
				return .compute(destination: destination, lhs: .immediate(first), operation: op, rhs: .location(second))
				
				case .binary(first: .location(location: let first), op: let op, second: .constant(value: let second)):
				return .compute(destination: destination, lhs: .location(first), operation: op, rhs: .immediate(second))
				
				case .binary(first: .location(location: let first), op: let op, second: .location(location: let second)):
				return .compute(destination: destination, lhs: .location(first), operation: op, rhs: .location(second))
				
				case .binary(first: let first, op: let op, second: let second):
				let firstLocation = context.allocateLocation()
				let secondLocation = context.allocateLocation()
				return .sequence(effects: [
					first.lowered(destination: firstLocation, context: &context),
					second.lowered(destination: secondLocation, context: &context),
					Self.binary(first: .location(location: firstLocation), op: op, second: .location(location: secondLocation))
						.lowered(destination: destination, context: &context)
				])
				
				case .conditional(predicate: let predicate, affirmative: let affirmative, negative: let negative):
				return .conditional(
					predicate:		predicate,
					affirmative:	affirmative.lowered(destination: destination, context: &context),
					negative:		negative.lowered(destination: destination, context: &context)
				)
				
			}
		}
		
	}
	
	public typealias BinaryOperator = Lower.BinaryOperator
	
}
