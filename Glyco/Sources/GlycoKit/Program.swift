// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation
import Sisp

public protocol Program : Codable, Equatable, Optimisable {
	
	/// Validates `self`.
	func validate() throws
	
	/// Returns a representation of `self` in a lower language.
	func lowered(configuration: CompilationConfiguration) throws -> LowerProgram
	
	/// A program in the lower language.
	associatedtype LowerProgram : Program
	
	/// Lowers `self` to S, encodes it into an object, and links it into an ELF executable.
	///
	/// This method must be implemented by languages that cannot be lowered. The default implementation lowers `self` and invokes `elf(configuration:)` on the lower language.
	func elf(configuration: CompilationConfiguration) throws -> Data
	
}

public struct CompilationConfiguration {
	
	/// Creates a configuration.
	public init(
		target:				Target,
		toolchainURL:		URL? = nil,
		systemURL:			URL? = nil,
		argumentRegisters:	[AL.Register] = AL.Register.defaultArgumentRegisters,
		optimise:			Bool = true,
		validate:			Bool = true
	) {
		self.target = target
		self.toolchainURL = toolchainURL ?? FileManager
			.default
			.homeDirectoryForCurrentUser
			.appendingPathComponent("cheri", isDirectory: true)
		self.systemURL = systemURL ?? self.toolchainURL
			.appendingPathComponent("output")
			.appendingPathComponent("rootfs-riscv64-purecap", isDirectory: true)
		self.argumentRegisters = argumentRegisters
		self.optimise = optimise
		self.validate = validate
	}
	
	/// The program's target platform.
	public var target: Target
	public enum Target : String, CaseIterable {
		
		/// The target platform is CheriBSD.
		case cheriBSD = "CheriBSD"
		
		/// The target platform is the CHERI-RISC-V Sail model.
		case sail = "Sail"
		
	}
	
	/// A URL to a CHERI-RISC-V toolchain.
	public var toolchainURL: URL
	
	/// A URL to a CheriBSD system root.
	public var systemURL: URL
	
	/// The registers used for passing arguments, in argument order.
	public var argumentRegisters: [AL.Register]
	
	/// A Boolean value indicating whether programs are optimised in each language before lowering them.
	public var optimise: Bool
	
	/// A Boolean value indicating whether programs are validated in each language before lowering them.
	public var validate: Bool
	
}

extension Program {
	
	public func optimise() -> Bool { false }
	
	public func validate() {}
	
	public func elf(configuration: CompilationConfiguration) throws -> Data {
		try processedLowering(configuration: configuration)
			.elf(configuration: configuration)
	}
	
	/// Optionally optimises and validates `self`, then returns a representation of `self` in a lower language.
	public func processedLowering(configuration: CompilationConfiguration) throws -> LowerProgram {
		var copy = self
		if configuration.optimise {
			copy.optimiseUntilFixedPoint()
		}
		if configuration.validate {
			try copy.validate()
		}
		return try copy.lowered(configuration: configuration)
	}
	
	public func write(to url: URL) throws {
		try SispEncoder()
			.encode(self)
			.serialised()
			.write(to: url, atomically: false, encoding: .utf8)
	}
	
}

extension Never : Program {
	
	public init(from decoder: Decoder) throws {
		fatalError("Cannot decode an instance of Never")
	}
	
	public func encode(to encoder: Encoder) throws {
		switch self {}
	}
	
	public func lowered(configuration: CompilationConfiguration) -> Self {
		switch self {}
	}
	
}
