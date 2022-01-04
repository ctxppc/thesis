// Glyco © 2021–2022 Constantino Tsarouhas

//sourcery: longname = Frame Locations
/// A language that introduces frame locations, i.e., memory locations relative to the frame capability `cfp`.
public enum FL : Language {
	
	/// A program in the base language.
	public struct Program : Codable, GlycoKit.Program {
		
		/// Creates a program with given instructions.
		public init(_ instructions: [Instruction] = []) {
			self.instructions = instructions
		}
		
		/// The program's instructions.
		public var instructions: [Instruction] = []
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			var frame = Frame()
			return .init(instructions: try instructions.lowered(in: &frame))
		}
		
		public enum CodingKeys : String, CodingKey {
			case instructions = "_0"
		}
		
	}
	
	// See protocol.
	public typealias Lower = RV
	
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias DataType = Lower.DataType
	public typealias Label = Lower.Label
	
}
