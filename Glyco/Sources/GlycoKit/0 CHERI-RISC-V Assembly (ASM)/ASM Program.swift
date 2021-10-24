// Glyco © 2021 Constantino Tsarouhas

import Foundation

public enum ASM : Language {
	
	/// A program in the ASM language.
	public struct Program : Codable, GlycoKit.Program {
		
		/// The program's assembly representation.
		public let assemblyRepresentation: String
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) -> Never {
			fatalError("Cannot lower ASM to another language; use `elf(configuration:)` to encode the assembly representation and link the executable.")
		}
		
		// See protocol.
		public func elf(configuration: CompilationConfiguration) -> Data {
			TODO.unimplemented
		}
		
	}
	
	// See protocol.
	public typealias Lower = Never
	
}
