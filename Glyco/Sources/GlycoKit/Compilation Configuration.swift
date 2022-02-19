// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

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
