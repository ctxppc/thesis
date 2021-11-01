// Glyco © 2021 Constantino Tsarouhas

public enum BB : Language {
	
	/// A program on an BB machine.
	public struct Program : Codable, GlycoKit.Program {
		
		/// The program's blocks.
		///
		/// The first block in the array is the program's entry point.
		public var blocks: [Block]
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) -> Lower.Program {
			.init(effects: blocks.flatMap { $0.lowered() })
		}
		
	}
	
	// See protocol.
	public typealias Lower = FO
	
}
