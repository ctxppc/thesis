// Glyco © 2021 Constantino Tsarouhas

public enum RV : Language {
	
	/// A program in the base language.
	public struct Program : Codable, GlycoKit.Program {
		
		/// The program's instructions.
		public var instructions: [Instruction] = []
		
		// See protocol.
		public func lowered() -> Never {
			fatalError("Cannot lower RV to another language; use `assembly()` to retrieve the program‘s assembly representation.")
		}
		
		// See protocol.
		public func compiled() -> String {
			"""
							.text
							.attribute	4, 16
							.attribute	5, "rv64i2p0_xcheri0p0"
							.file		"<unknown>.gly"
							
							# -- Begin function _start
							.globl		_start
							.p2align	2
							.type		_start, @function
			_start:			\(instructions
								.map { $0.compiled() }
								.joined(separator: "\n\t\t\t\t"))
			.Lfunc_end0:	.size		_start, .Lfunc_end0-_start
							# -- End function _start
							
							.ident		"glyco version 0.1"
							.section	".note.GNU-stack","",@progbits
							.addrsig
			"""
		}
		
	}
	
	// See protocol.
	public typealias Lower = Never
	
}
