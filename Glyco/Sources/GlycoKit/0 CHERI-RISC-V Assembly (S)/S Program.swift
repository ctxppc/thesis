// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

//sourcery: longname = CHERI-RISC-V Assembly
//sourcery: description = The ground language as provided to Clang for assembly and linking.
public enum S : Language {
	
	/// A program in the S language.
	public struct Program : Codable, GlycoKit.Program {
		
		// See protocol.
		//sourcery: isInternalForm
		public init(fromEncoded encoded: String) throws {
			self.init(assembly: encoded)
		}
		
		/// Creates a program with given assembly.
		public init(assembly: String) {
			self.assembly = assembly
		}
		
		/// The program's assembly representation.
		public let assembly: String
		
		// See protocol.
		public func optimise() -> Bool { false }
		
		// See protocol.
		public func validate() {}
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) -> Never {
			fatalError("Cannot lower S to another language; use `elf(configuration:)` to encode the assembly representation and link the executable.")
		}
		
		/// Encodes `self` into an object and links the object into an ELF executable.
		public func elf(configuration: CompilationConfiguration) throws -> Data {
			
			let tmpURL = try FileManager.default.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: configuration.toolchainURL, create: true)
			defer { try? FileManager.default.removeItem(at: tmpURL) }
			
			let assemblyURL = tmpURL.appendingPathComponent("asm.S")
			let elfURL = tmpURL.appendingPathComponent("elf")
			try assembly.write(to: assemblyURL, atomically: false, encoding: .utf8)
			
			let clang = Process()
			clang.executableURL = configuration.toolchainURL
				.appendingPathComponent("output")
				.appendingPathComponent("sdk")
				.appendingPathComponent("bin")
				.appendingPathComponent("clang", isDirectory: false)
			
			clang.arguments = {
				switch configuration.target {
					
					case .cheriBSD:
					return [
						"-target", "riscv64-unknown-freebsd",
						"--sysroot=\(configuration.systemURL.path)",
						"-fuse-ld=lld",
					]
					
					case .sail:
					return [
						"-target", "riscv64-unknown-elf-64",
						"-nostdlib",
						"-Ttext", "0x0000000080000000",
					]
					
				}
			}() + [
				"-O2",
				"-mabi=lp64d",
				"-march=rv64gcxcheri",
				"-mno-relax",
				"-Wall", "-Wcheri",
				assemblyURL.path, "-o", elfURL.path,
			]
			
			try clang.run()
			clang.waitUntilExit()
			guard clang.terminationStatus == 0 else { throw CompilationError.clangError(code: clang.terminationStatus) }
			
			return try Data(contentsOf: elfURL)
			
		}
		
		// See protocol.
		public func encoded() throws -> String { assembly }
		
	}
	
	enum CompilationError : LocalizedError {
		case clangError(code: Int32)
		var errorDescription: String? {
			switch self {
				case .clangError(code: let code):	return "Clang exited with code \(code)."
			}
		}
	}
	
	// See protocol.
	public typealias Lower = Never
	
	// See protocol.
	public static func reduce<R : ProgramReductor>(_ program: Program, using reductor: R, configuration: CompilationConfiguration) throws -> R.Result {
		var reductor = reductor
		return try reductor.update(language: self, program: program) ?? reductor.result()
	}
	
	// See protocol.
	public static func iterate<Action : LanguageAction, Result>(_ action: Action) throws -> Result? where Action.Result == Result? {
		try action(language: self)
	}
	
}
