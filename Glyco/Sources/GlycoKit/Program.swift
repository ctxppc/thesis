// Glyco © 2021 Constantino Tsarouhas

import Foundation

public protocol Program {
	
	/// Returns a representation of `self` in a lower language.
	func lowered(configuration: CompilationConfiguration) -> LowerProgram
	
	/// A program in the lower language.
	associatedtype LowerProgram : Program
	
	/// Lowers `self` to ASM, encodes it into an object, and links it into an ELF executable.
	///
	/// This method must be implemented by languages that cannot be lowered. The default implementation lowers `self` and invokes `elf(configuration:)` on the lower language.
	func elf(configuration: CompilationConfiguration) -> Data
	
}

public struct CompilationConfiguration {
	
	/// Creates a configuration.
	public init(target: Target) {
		self.target = target
	}
	
	/// The program's target platform.
	public var target: Target
	public enum Target {
		
		/// The target platform is CheriBSD.
		case cheriBSD
		
		/// The target platform is the CHERI-RISC-V Sail model.
		case sail
		
	}
	
}

extension Program {
	public func elf(configuration: CompilationConfiguration) -> Data {
		lowered(configuration: configuration)
			.elf(configuration: configuration)
	}
}

extension Never : Program {
	public func lowered(configuration: CompilationConfiguration) -> Self {
		switch self {}
	}
}
