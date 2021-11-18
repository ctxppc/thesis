// Glyco © 2021 Constantino Tsarouhas

/// A language that groups effects into blocks of effects where blocks can only be entered at a single entry point and exited at a single exit point.
public enum BB : Language {
	
	/// A program on an BB machine.
	public struct Program : Codable, GlycoKit.Program {
		
		/// Creates a program with given blocks
		public init(blocks: [BB.Block]) {
			self.blocks = blocks
		}
		
		/// The program's blocks.
		///
		/// Exactly one block must be labelled with `.entry`.
		public var blocks: [Block]
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			.init(effects: try blocks.lowered())
		}
		
	}
	
	// See protocol.
	public typealias Lower = FO
	
	public typealias Frame = Lower.Frame
	public typealias Register = Lower.Register
	
}
