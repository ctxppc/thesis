// Glyco © 2021–2022 Constantino Tsarouhas

import DepthKit
import Foundation

/// The ground language as provided to Clang for assembly and linking.
public enum S : Language {
	
	/// A program in the S language.
	public struct Program : Codable, GlycoKit.Program {
		
		/// The program's assembly representation.
		public let body: String
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) -> Never {
			fatalError("Cannot lower S to another language; use `elf(configuration:)` to encode the assembly representation and link the executable.")
		}
		
		// See protocol.
		public func elf(configuration: CompilationConfiguration) throws -> Data {
			
			let tmpURL = try FileManager.default.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: configuration.toolchainURL, create: true)
			defer { try? FileManager.default.removeItem(at: tmpURL) }
			
			let assemblyURL = tmpURL.appendingPathComponent("asm.S")
			let elfURL = tmpURL.appendingPathComponent("elf")
			try body.write(to: assemblyURL, atomically: false, encoding: .utf8)
			
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
						"-mabi=l64pc128d",
					]
					
					case .sail:
					return [
						"-target", "riscv64-unknown-elf-64",
						"-nostdlib",
						"-march=rv64gcxcheri",
						"-Ttext", "0x0000000080000000",
					]
					
				}
			}() + [
				"-O2",
				"-march=rv64gcxcheri",
				"-mno-relax",
				"-Wall", "-Wcheri",
				assemblyURL.path, "-o", elfURL.path,
			]
			
			try clang.run()
			clang.waitUntilExit()
			guard clang.terminationStatus == 0 else { throw CompilationError.clangError }
			
			return try Data(contentsOf: elfURL)
			
		}
		
	}
	
	enum CompilationError : LocalizedError {
		case clangError
		var errorDescription: String? {
			switch self {
				case .clangError:	return "Clang exited with a nonzero code."
			}
		}
	}
	
	// See protocol.
	public typealias Lower = Never
	
	// See protocol.
	public static func loweredProgramRepresentation(fromData data: Data, sourceLanguage: String, targetLanguage: String, configuration: CompilationConfiguration) throws -> String {
		guard isNamed(sourceLanguage) else { throw LoweringError.unknownLanguage(sourceLanguage) }
		guard isNamed(targetLanguage) else { throw LoweringError.unknownLanguage(targetLanguage) }
		guard let assembly = String(data: data, encoding: .utf8) else { throw LoweringError.invalidEncoding }
		return assembly
	}
	
	// See protocol.
	public static func loweredProgramRepresentation(_ program: Program, targetLanguage: String, configuration: CompilationConfiguration) throws -> String {
		guard isNamed(targetLanguage) else { throw LoweringError.unknownLanguage(targetLanguage) }
		return program.body
	}
	
	// See protocol.
	public static func elfFromProgram(fromData data: Data, sourceLanguage: String, configuration: CompilationConfiguration) throws -> Data {
		guard isNamed(sourceLanguage) else { throw LoweringError.unknownLanguage(sourceLanguage) }
		guard let assembly = String(data: data, encoding: .utf8) else { throw LoweringError.invalidEncoding }
		return try Program(body: assembly).elf(configuration: configuration)
	}
	
	enum LoweringError : LocalizedError {
		case unknownLanguage(String)
		case invalidEncoding
		var errorDescription: String? {
			switch self {
				case .unknownLanguage(let language):	return "“\(language)” is not a language supported by Glyco."
				case .invalidEncoding:					return "Expected S in UTF-8."
			}
		}
	}
	
}
