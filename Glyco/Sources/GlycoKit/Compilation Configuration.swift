// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

public struct CompilationConfiguration {
	
	/// Creates a configuration.
	public init(target: Target, toolchainURL: URL? = nil, systemURL: URL? = nil, callingConvention: CallingConvention = .conventional) {
		
		self.target = target
		self.toolchainURL = toolchainURL ?? FileManager
			.default
			.homeDirectoryForCurrentUser
			.appendingPathComponent("cheri", isDirectory: true)
		self.systemURL = systemURL ?? self.toolchainURL
			.appendingPathComponent("output")
			.appendingPathComponent("rootfs-riscv64-purecap", isDirectory: true)
		self.callingConvention = callingConvention
		
		(callerSavedRegisters, calleeSavedRegisters) = {
			switch callingConvention {
				case .conventional:	return (AL.Register.callerSavedRegistersInRVABI, AL.Register.calleeSavedRegistersInRVABI)
				case .heap:			return (AL.Register.callerSavedRegistersInCHERIRVABI, AL.Register.calleeSavedRegistersInCHERIRVABI)
			}
		}()
		
	}
	
	// MARK: - Target
	
	/// The program's target platform.
	public var target: Target
	public enum Target : String, CaseIterable {
		
		/// The target platform is CheriBSD.
		case cheriBSD
		
		/// The target platform is the CHERI-RISC-V Sail model.
		case sail
		
	}
	
	// MARK: Procedure Calls
	
	/// The program's calling convention.
	public var callingConvention: CallingConvention
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
	
	/// The registers used for passing arguments, in argument order.
	public var argumentRegisters: [AL.Register] = AL.Register.argumentRegistersInRVABI
	
	/// The registers that a callee must save before redefining.
	public var calleeSavedRegisters: [AL.Register]
	
	/// The registers that a caller must save or discard before invoking a procedure.
	public var callerSavedRegisters: [AL.Register]
	
	/// A Boolean value indicating whether the lifetime of caller-saved registers is limited by copying their contents to abstract locations.
	public var limitsCallerSavedRegisterLifetimes: Bool = true
	
	// MARK: - Memory
	
	/// The size of the heap, in bytes.
	///
	/// The default size is 1 MiB.
	public var heapByteSize: Int = 1 << 20
	
	/// The size of the call stack, in bytes, when a contiguous stack is used.
	///
	/// The default size is 1 MiB.
	public var stackByteSize: Int = 1 << 20
	
	// MARK: - Toolchain
	
	/// A URL to a CHERI-RISC-V toolchain.
	public var toolchainURL: URL
	
	/// A URL to a CheriBSD system root.
	public var systemURL: URL
	
	// MARK: Pipeline
	
	/// A Boolean value indicating whether programs are optimised in each language before lowering them.
	public var optimise: Bool = true
	
	/// A Boolean value indicating whether programs are validated in each language before lowering them.
	public var validate: Bool = true
	
	// MARK: Output
	
	/// The (suggested) maximum line length of serialised output programs.
	public var maximumLineLength: Int = 120
	
}
