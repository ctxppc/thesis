// Glyco © 2021 Constantino Tsarouhas

public enum BB : Language {
	
	/// A program on an BB machine.
	public struct Program : Codable, GlycoKit.Program {
		
		/// The program's blocks.
		///
		/// Exactly one block must be labelled with `.entry`.
		public var blocks: [Block]
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) -> Lower.Program {
			.init(effects: blocks.lowered())
		}
		
	}
	
	// See protocol.
	public typealias Lower = FO
	
	public typealias Frame = Lower.Frame
	public typealias Register = Lower.Register
	
}
