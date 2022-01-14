// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

extension FO {
	
	/// An FO effect where the machine halts execution of the program.
	public struct HaltEffect : Codable, Equatable, SimplyLowerable {
		
		public init(result: Source, type: DataType) {
			self.result = result
			self.type = type
		}
		
		/// The source of the result value.
		public var result: Source
		
		/// The data type of the result value.
		public var type: DataType
		
		// See protocol.
		public func lowered(in context: inout ()) throws -> Lower.Effect {
			switch result {
				
				case .immediate(let imm):
				guard type != .capability else { throw LoweringError.returningCapabilityUsingImmediate }
				return .compute(into: .a0, value: .zero + imm)
				
				case .location(.register(let result)):
				return .copy(type, into: .a0, from: try result.lowered())
				
				case .location(.frameCell(let result)):
				return .load(type, into: .a0, from: result)
				
			}
		}
		
		enum LoweringError : LocalizedError {
			case returningCapabilityUsingImmediate
			var errorDescription: String? {
				switch self {
					case .returningCapabilityUsingImmediate:	return "Cannot return a capability using an immediate"
				}
			}
		}
		
	}
	
}
