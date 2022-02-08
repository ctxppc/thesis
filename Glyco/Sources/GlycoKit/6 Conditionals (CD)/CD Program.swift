// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

//sourcery: longname = Conditionals
//sourcery: description = "A language that introduces conditionals in effects and predicates, thereby abstracting over blocks (and jumps)."
public enum CD : Language {
	
	/// A program on an CD machine.
	public struct Program : Codable, GlycoKit.Program {
		
		public init(_ effect: Effect, procedures: [Procedure]) {
			self.effect = effect
			self.procedures = procedures
		}
		
		/// The program's effect.
		public var effect: Effect
		
		/// The program's procedures.
		public var procedures: [Procedure]
		
		// See protocol.
		public mutating func optimise() throws -> Bool {
			let effectOptimised = try effect.optimise()
			let proceduresOptimised = try procedures.optimise()
			return effectOptimised || proceduresOptimised
		}
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			guard effect.allExecutionPathsTerminate else { throw LoweringError.someExecutionPathsDoNotTerminate }
			var context = Context()
			return .init(try (procedures + [.init(.programEntry, in: effect)]).lowered(in: &context))
		}
		
		enum LoweringError : LocalizedError {
			
			/// An error indicating that some execution paths do not terminate.
			case someExecutionPathsDoNotTerminate
			
			// See protocol.
			var errorDescription: String? {
				switch self {
					case .someExecutionPathsDoNotTerminate:	return "Some execution paths do not terminate."
				}
			}
			
		}
		
	}
	
	// See protocol.
	public typealias Lower = PR
	
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias DataType = Lower.DataType
	public typealias Frame = Lower.Frame
	public typealias Label = Lower.Label
	public typealias Location = Lower.Location
	public typealias Register = Lower.Register
	public typealias Source = Lower.Source
	
}
