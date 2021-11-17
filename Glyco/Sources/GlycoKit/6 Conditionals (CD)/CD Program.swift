// Glyco © 2021 Constantino Tsarouhas

/// A language that introduces conditionals in effects and predicates, thereby abstracting over blocks (and jumps).
public enum CD : Language {
	
	/// A program on an CD machine.
	public struct Program : Codable, GlycoKit.Program {
		
		/// The program's effect.
		public var effect: Effect
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			var context = Context()
			return .init(
				blocks: try effect
					.optimised()
					.lowered(in: &context, entryLabel: .programEntry, previousEffects: [], exitLabel: .programExit)
			)
		}
		
	}
	
	// See protocol.
	public typealias Lower = PR
	
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias Frame = Lower.Frame
	public typealias Label = Lower.Label
	public typealias Location = Lower.Location
	public typealias Register = Lower.Register
	public typealias Source = Lower.Source
	
}
