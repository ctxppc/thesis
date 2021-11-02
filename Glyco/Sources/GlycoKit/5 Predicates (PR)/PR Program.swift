// Glyco © 2021 Constantino Tsarouhas

public enum PR : Language {
	
	/// A program on a PR machine.
	public struct Program : Codable, GlycoKit.Program {
		
		/// The program's blocks.
		///
		/// The first block in the array is the program's entry point.
		public var blocks: [Block]
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) -> Lower.Program {
			.init(blocks: blocks.lowered())
		}
		
	}
	
	// See protocol.
	public typealias Lower = BB
	
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias Location = Lower.Location
	public typealias Frame = Lower.Frame
	
}
