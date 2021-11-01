// Glyco © 2021 Constantino Tsarouhas

public enum FO : Language {
	
	/// An FO program.
	public struct Program : Codable, GlycoKit.Program {
		
		/// The effects of the program.
		public var effects: [Effect]
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) -> Lower.Program {
			.init(instructions: effects.lowered())
		}
		
	}
	
	// See protocol.
	public typealias Lower = FL
	
}
