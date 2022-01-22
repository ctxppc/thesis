// Glyco © 2021–2022 Constantino Tsarouhas

import DepthKit

extension ALA {
	
	/// An effect on an ALA machine.
	public enum Effect : Codable, Equatable, SimplyLowerable {
		
		/// An effect that performs `effects`.
		case `do`([Effect], Analysis)
		
		/// An effect that retrieves the value from given source and puts it in given location.
		case set(DataType, Location, to: Source, Analysis)
		
		/// An effect that computes `lhs` `operation` `rhs` and puts it in `to`.
		case compute(Source, BinaryOperator, Source, to: Location, Analysis)
		
		/// An effect that retrieves the element at zero-based position `at` in the vector in `of` and puts it in `to`.
		case getElement(DataType, of: Location, at: Source, to: Location, Analysis)
		
		/// An effect that evaluates `to` and puts it in the vector in `of` at zero-based position `at`.
		case setElement(DataType, of: Location, at: Source, to: Source, Analysis)
		
		/// An effect that performs `then` if the predicate holds, or `else` otherwise.
		indirect case `if`(Predicate, then: Effect, else: Effect, Analysis)
		
		/// An effect that invokes the labelled procedure and uses given locations.
		///
		/// This effect assumes a suitable calling convention has already been applied to the program. The parameter locations are only used for the purposes of liveness analysis.
		case call(Label, Analysis)
		
		/// An effect that terminates the program with `result`.
		case `return`(DataType, Source, Analysis)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Effect {
			switch self {
				
				case .do(let effects, _):
				return .do(try effects.lowered(in: &context))
				
				case .set(let dataType, let destination, to: let source, _):
				return try .set(dataType, destination.lowered(in: &context), to: source.lowered(in: &context))
				
				case .compute(let lhs, let op, let rhs, to: let destination, _):
				return try .compute(lhs.lowered(in: &context), op, rhs.lowered(in: &context), to: destination.lowered(in: &context))
				
				case .getElement(let dataType, of: let vector, at: let index, to: let destination, _):
				return try .getElement(dataType, of: vector.lowered(in: &context), at: index.lowered(in: &context), to: destination.lowered(in: &context))
				
				case .setElement(let dataType, of: let vector, at: let index, to: let source, _):
				return try .setElement(dataType, of: vector.lowered(in: &context), at: index.lowered(in: &context), to: source.lowered(in: &context))
				
				case .if(let predicate, then: let affirmative, else: let negative, _):
				return try .if(predicate.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .call(let name, _):
				return .call(name)
				
				case .return(let dataType, let value, _):
				return .return(dataType, try value.lowered(in: &context))
				
			}
		}
		
		/// The analysis for `self`.
		var analysis: Analysis {
			switch self {
				case .do(_, let analysis):								return analysis
				case .set(_, _, to: _, let analysis):					return analysis
				case .compute(_, _, _, to: _, let analysis):			return analysis
				case .getElement(_, of: _, at: _, to: _, let analysis):	return analysis
				case .setElement(_, of: _, at: _, to: _, let analysis):	return analysis
				case .if(_, then: _, else: _, let analysis):			return analysis
				case .call(_, let analysis):							return analysis
				case .return(_, _, let analysis):						return analysis
			}
		}
		
	}
	
}
