// Glyco © 2021–2022 Constantino Tsarouhas

//sourcery: longname = Flexible Operands
//sourcery: description = "A language that introduces flexible operands in instructions, i.e., instructions that can take frame locations in all operand positions."
public enum FO : Language {
	
	/// An FO program.
	public struct Program : GlycoKit.Program {
		
		/// Creates a program with given effects.
		public init(_ effects: [Effect]) {
			self.effects = effects
		}
		
		/// The effects of the program, starting with the program's first effect.
		public var effects: [Effect]
		
		// See protocol.
		public func optimise(configuration: CompilationConfiguration) -> Bool { false }
		
		// See protocol.
		public func validate(configuration: CompilationConfiguration) {}
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			.init(try effects.lowered())
		}
		
	}
	
	/// A temporary register reserved for FO.
	static let (tempRegisterA, tempRegisterB) = (Lower.Register.t4, Lower.Register.t5)
	
	// See protocol.
	public typealias Lower = MM
	
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias DataType = Lower.DataType
	public typealias Label = Lower.Label
	
}
