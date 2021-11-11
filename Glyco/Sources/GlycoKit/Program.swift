// Glyco © 2021 Constantino Tsarouhas

import Foundation
import Yams

public protocol Program : Codable, Equatable {
	
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
	public init(target: Target, toolchainURL: URL? = nil, systemURL: URL? = nil) {
		self.target = target
		self.toolchainURL = toolchainURL ?? FileManager
			.default
			.homeDirectoryForCurrentUser
			.appendingPathComponent("cheri", isDirectory: true)
		self.systemURL = systemURL ?? self.toolchainURL
			.appendingPathComponent("output")
			.appendingPathComponent("rootfs-riscv64-purecap", isDirectory: true)
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
	
}

extension Program {
	
	public func elf(configuration: CompilationConfiguration) throws -> Data {
		try lowered(configuration: configuration)
			.elf(configuration: configuration)
	}
	
	public func write(to url: URL) throws {
		try YAMLEncoder().encode(self).write(to: url, atomically: false, encoding: .utf8)
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
