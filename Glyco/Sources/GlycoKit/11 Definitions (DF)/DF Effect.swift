// Glyco © 2021–2022 Constantino Tsarouhas

import DepthKit
import Foundation

extension DF {
	
	/// An effect on a DF machine.
	public enum Effect : Codable, Equatable, SimplyLowerable {
		
		/// An effect that performs given effects.
		case `do`([Effect])
		
		/// An effect that performs given effect after associating zero or more values with a name.
		indirect case `let`([Definition], in: Effect)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Effect {
			switch self {
				
				case .do(let effects):
				return .do(try effects.lowered(in: &context))
				
				case .let(let definitions, in: let effect):
				return try .do(definitions.lowered(in: &context) + [effect.lowered(in: &context)])
				
			}
		}
		
	}
	
}
