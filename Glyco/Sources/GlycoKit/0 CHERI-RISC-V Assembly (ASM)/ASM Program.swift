// Glyco © 2021 Constantino Tsarouhas

import DepthKit
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
				"clang",
				"-O2",
				"-target", "riscv64-unknown-freebsd",
				"--sysroot=\(configuration.systemURL.absoluteString)",
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
			let assemblyURL = tmpURL.appendingPathComponent("asm.S")
			let linkerCommandsURL = tmpURL.appendingPathComponent("linkage.ld")
			let elfURL = tmpURL.appendingPathComponent("elf")
			
			try assemblyRepresentation.write(to: assemblyURL, atomically: false, encoding: .utf8)
			defer { try? FileManager.default.removeItem(at: assemblyURL) }
			
			try linkerCommands.write(to: linkerCommandsURL, atomically: false, encoding: .utf8)
			defer { try? FileManager.default.removeItem(at: linkerCommandsURL) }
			
			clangArguments += [
				linkerCommandsURL.absoluteString, assemblyURL.absoluteString,
				"-o", elfURL.absoluteString
			]
			
			let clang = Process()
			clang.executableURL = configuration.toolchainURL
				.appendingPathComponent("output")
				.appendingPathComponent("sdk")
				.appendingPathComponent("bin")
				.appendingPathComponent("clang", isDirectory: false)
			clang.arguments = clangArguments
			
			try clang.run()
			defer { try? FileManager.default.removeItem(at: elfURL) }
			clang.waitUntilExit()
			
			return try Data(contentsOf: elfURL)
			
		}
		
	}
	
	// See protocol.
	public typealias Lower = Never
	
}
