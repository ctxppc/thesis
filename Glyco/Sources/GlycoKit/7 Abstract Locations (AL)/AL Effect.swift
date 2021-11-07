// Glyco © 2021 Constantino Tsarouhas

import DepthKit

extension AL {
	
	/// An effect on an AL machine.
	public enum Effect : Codable, SimplyLowerable {
		
		/// An effect that does nothing.
		case none
		
		/// An effect that retrieves the value in `source` and puts it in `destination`, then performs `successor`.
		indirect case copy(destination: Location, source: Source, successor: Effect)
		
		/// An effect that computes `lhs` `operation` `rhs` and puts it in `destination`, then performs `successor`.
		indirect case compute(destination: Location, lhs: Source, operation: BinaryOperator, rhs: Source, successor: Effect)
		
		/// An effect that performs `affirmative` if `predicate` holds, or `negative` otherwise, then performs `successor`.
		indirect case conditional(predicate: Predicate, affirmative: Effect, negative: Effect, successor: Effect)
		
		/// An effect that terminates with `result`.
		case `return`(result: Source)
		
		// See protocol.
		func lowered(in context: inout Context) -> Lower.Effect {
			switch self {
				
				case .none:
				return .none
				
				case .copy(destination: let destination, source: let source, successor: let successor):
				return .copy(
					destination:	destination.lowered(in: &context),
					source:			source.lowered(in: &context),
					successor:		successor.lowered(in: &context)
				)
				
				case .compute(destination: let destination, lhs: let lhs, operation: let operation, rhs: let rhs, successor: let successor):
				return .compute(
					destination:	destination.lowered(in: &context),
					lhs:			lhs.lowered(in: &context),
					operation:		operation,
					rhs:			rhs.lowered(in: &context),
					successor:		successor.lowered(in: &context)
				)
				
				case .conditional(predicate: let predicate, affirmative: let affirmative, negative: let negative, successor: let successor):
				return .conditional(
					predicate:		predicate.lowered(in: &context),
					affirmative:	affirmative.lowered(in: &context),
					negative:		negative.lowered(in: &context),
					successor:		successor.lowered(in: &context)
				)
				
				case .return(result: let result):
				return .return(result: result.lowered(in: &context))
				
			}
		}
		
		/// Returns a copy of `self` where `successor` is the successor.
		///
		/// This method returns `self` unchanged if `self` is a return effect.
		public func then(_ successor: Self) -> Self {
			switch self {
				
				case .none:
				return successor
				
				case .copy(destination: let destination, source: let source, successor: _):
				return .copy(destination: destination, source: source, successor: successor)
				
				case .compute(destination: let destination, lhs: let lhs, operation: let operation, rhs: let rhs, successor: _):
				return .compute(destination: destination, lhs: lhs, operation: operation, rhs: rhs, successor: successor)
				
				case .conditional(predicate: let predicate, affirmative: let affirmative, negative: let negative, successor: _):
				return .conditional(predicate: predicate, affirmative: affirmative, negative: negative, successor: successor)
				
				case .return:
				return self
				
			}
		}
		
	}
	
	public typealias BinaryOperator = Lower.BinaryOperator
	
}

public func <- (destination: AL.Location, source: AL.Source) -> AL.Effect {
	.copy(destination: destination, source: source, successor: .return(result: source))
}
