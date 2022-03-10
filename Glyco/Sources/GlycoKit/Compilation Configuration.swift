// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

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
		case cheriBSD
		
		/// The target platform is the CHERI-RISC-V Sail model.
		case sail
		
	}
	
	/// The program's calling convention.
	public var callingConvention: CallingConvention = .conventional
	public enum CallingConvention : String, CaseIterable {
		
		/// The Glyco Conventional Calling Convention (GCCC), a calling convention based on a traditional RISC-V calling convention.
		case conventional
		
		/// The Glyco Heap-based Secure Calling Convention (GHSCC), a calling convention enforcing stack encapsulation but no well-bracketed control flow.
		case heap
		
		/// A Boolean value indicating whether a contiguous call stack is used.
		var usesContiguousCallStack: Bool {
			switch self {
				case .conventional:	return true
				case .heap:			return false
			}
		}
		
		/// A Boolean value indicating whether the calling convention uses a call routine provided by the runtime, i.e., whether an scall is required, as opposed to the caller jumping directly to the callee.
		var requiresCallRoutine: Bool {
			switch self {
				case .conventional:	return false
				case .heap:			return true
			}
		}
		
	}
	
	/// A URL to a CHERI-RISC-V toolchain.
	public var toolchainURL: URL
	
	/// A URL to a CheriBSD system root.
	public var systemURL: URL
	
	/// The registers used for passing arguments, in argument order.
	public var argumentRegisters: [AL.Register] = AL.Register.argumentRegistersInRVABI
	
	/// A Boolean value indicating whether programs are optimised in each language before lowering them.
	public var optimise: Bool = true
	
	/// A Boolean value indicating whether programs are validated in each language before lowering them.
	public var validate: Bool = true
	
	/// The size of the heap, in bytes.
	///
	/// The default size is 1 MiB.
	public var heapByteSize: Int = 1 << 20
	
	/// The (suggested) maximum line length of serialised output programs.
	public var maximumLineLength: Int = 120
	
}
