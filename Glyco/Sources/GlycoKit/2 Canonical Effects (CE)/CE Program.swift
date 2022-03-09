// Glyco © 2021–2022 Constantino Tsarouhas

//sourcery: longname = Canonical Effects
//sourcery: description = "A language grouping related instructions under a single effect."
public enum CE : Language {
	
	/// A CE program.
	public struct Program : Codable, GlycoKit.Program {
		
		/// Creates a program with given effects.
		public init(_ effects: [Effect] = []) {
			self.effects = effects
		}
		
		//sourcery: isInternalForm
		public init(@ArrayBuilder<Effect> _ effects: () throws -> [Effect]) rethrows {
			self.init(try effects())
		}
		
		/// The program's effects.
		public var effects: [Effect] = []
		
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
	public typealias Lower = RV
	
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias Label = Lower.Label
	public typealias Register = Lower.Register
	
}
