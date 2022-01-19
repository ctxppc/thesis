// Glyco © 2021–2022 Constantino Tsarouhas

//sourcery: longname = Frame Locations
//sourcery: description = "A language that introduces frame locations, i.e., memory locations relative to the frame capability `cfp`."
public enum FL : Language {
	
	/// A program in the base language.
	public struct Program : Codable, GlycoKit.Program {
		
		/// Creates a program with given effects.
		public init(_ effects: [Effect] = []) {
			self.effects = effects
		}
		
		/// The program's effects.
		public var effects: [Effect] = []
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			var frame = Frame()
			return .init(try effects.lowered(in: &frame))
		}
		
	}
	
	// See protocol.
	public typealias Lower = RV
	
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias DataType = Lower.DataType
	public typealias Label = Lower.Label
	
}
