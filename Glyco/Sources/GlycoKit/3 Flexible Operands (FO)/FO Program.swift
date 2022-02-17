// Glyco © 2021–2022 Constantino Tsarouhas

//sourcery: longname = Flexible Operands
//sourcery: description = "A language that introduces flexible operands in instructions, i.e., instructions that can take frame locations in all operand positions."
public enum FO : Language {
	
	/// An FO program.
	public struct Program : Codable, GlycoKit.Program {
		
		/// Creates a program with given effects.
		public init(_ effects: [Effect]) {
			self.effects = effects
		}
		
		/// The effects of the program.
		public var effects: [Effect]
		
		// See protocol.
		public func optimise() -> Bool { false }
		
		// See protocol.
		public func validate() {}
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			.init(try effects.lowered())
		}
		
	}
	
	// See protocol.
	public typealias Lower = CF
	
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias DataType = Lower.DataType
	public typealias Label = Lower.Label
	
}
