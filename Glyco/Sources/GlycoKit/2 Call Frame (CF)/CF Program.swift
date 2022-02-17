// Glyco © 2021–2022 Constantino Tsarouhas

//sourcery: longname = Call Frame
//sourcery: description = "A language that introduces call frames and operations for managing the call frame."
public enum CF : Language {
	
	/// A program in the base language.
	public struct Program : Codable, GlycoKit.Program {
		
		/// Creates a program with given effects.
		public init(_ effects: [Effect] = []) {
			self.effects = effects
		}
		
		/// The program's effects.
		public var effects: [Effect] = []
		
		// See protocol.
		public func optimise() -> Bool { false }
		
		// See protocol.
		public func validate() {}
		
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
	public typealias Label = Lower.Label
	
}
