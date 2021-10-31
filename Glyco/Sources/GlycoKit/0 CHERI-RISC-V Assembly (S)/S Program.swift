// Glyco © 2021 Constantino Tsarouhas

import DepthKit
import Foundation

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
			
			let linkerCommands = """
				OUTPUT_ARCH("riscv")
				ENTRY(_start)
				SECTIONS {
				  . = 0x80000000;
				  .text.init : { *(.text.init) }
				  . = ALIGN(0x1000);
				  .tohost : { *(.tohost) }
				  . = ALIGN(0x1000);
				  .text : { *(.text) }
				  . = ALIGN(0x1000);
				  .data : { *(.data) }
				  .bss : { *(.bss) }
				  _end = .;
				}
				"""
			
			var clangArguments = [
				"-O2",
				"-target", "riscv64-unknown-freebsd",
				"--sysroot=\(configuration.systemURL.path)",
				"-fuse-ld=lld",
				"-mno-relax",
				"-march=rv64gcxcheri",
				"-mabi=l64pc128d",
				"-Wall", "-Wcheri",
			]
			if configuration.target == .sail {
				clangArguments += ["-nostartfiles", "-nostdlib", "-static"]
			}
			
			let tmpURL = try FileManager.default.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: configuration.toolchainURL, create: true)
			defer { try? FileManager.default.removeItem(at: tmpURL) }
			
			let assemblyURL = tmpURL.appendingPathComponent("asm.S")
			let linkerCommandsURL = tmpURL.appendingPathComponent("linkage.ld")
			let elfURL = tmpURL.appendingPathComponent("elf")
			
			try body.write(to: assemblyURL, atomically: false, encoding: .utf8)
			try linkerCommands.write(to: linkerCommandsURL, atomically: false, encoding: .utf8)
			
			if configuration.target == .sail {
				clangArguments.append(linkerCommandsURL.path)
			}
			
			clangArguments += [
				assemblyURL.path, "-o", elfURL.path
			]
			
			let clang = Process()
			clang.executableURL = configuration.toolchainURL
				.appendingPathComponent("output")
				.appendingPathComponent("sdk")
				.appendingPathComponent("bin")
				.appendingPathComponent("clang", isDirectory: false)
			clang.arguments = clangArguments
			
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
