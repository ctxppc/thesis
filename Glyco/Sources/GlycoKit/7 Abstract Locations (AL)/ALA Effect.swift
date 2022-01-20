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
		case call(Label, [ParameterLocation], Analysis)
		
		/// An effect that terminates the program with `result`.
		case `return`(DataType, Source, Analysis)
		
		// See protocol.
		func lowered(in context: inout LocalContext) throws -> Lower.Effect {
			TODO.unimplemented
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
				case .call(_, _, let analysis):							return analysis
				case .return(_, _, let analysis):						return analysis
			}
		}
		
	}
	
}
