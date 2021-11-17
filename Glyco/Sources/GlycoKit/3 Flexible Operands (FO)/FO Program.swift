// Glyco © 2021 Constantino Tsarouhas

/// A language that introduces flexible operands in instructions, i.e., instructions that can take frame locations in all operand positions.
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
