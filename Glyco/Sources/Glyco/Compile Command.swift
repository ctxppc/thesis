// Glyco © 2021 Constantino Tsarouhas

import ArgumentParser
import DepthKit
import Foundation
import GlycoKit
import Yams

@main
struct CompileCommand : ParsableCommand {
	
	// See protocol.
	static let configuration = CommandConfiguration(commandName: "Glyco", abstract: "Compiles Gly source files to CHERI-RISC-V executables.", discussion: discussion)
	
	private static let discussion = """
	Glyco requires a CHERI-RISC-V toolchain and a CheriBSD system root, as built by cheribuild. The path to the toolchain can be provided through the CHERITOOLCHAIN environment variable; if omitted, Glyco assumes it‘s in ~/cheri. The path to the system root can be provided through the CHERISYSROOT environment variable; if omitted, Glyco assumes it‘s in output/rootfs-riscv64-purecap within the toolchain.
	"""
	
	@Argument(help: "The path to a Gly or intermediate file. The file‘s extension must be .gly or the lowercased name of an intermediate language (e.g., .fo).")
	var source: String
	
	@Option(name: .shortAndLong, help: "The intermediate language (ASM, FL, FO, etc.) to emit. Omit to build an ELF file.")
	var language: String?
	
	@Option(name: .shortAndLong, help: "The path of the generated file (will be overwritten). Omit to discard the ELF file or to print the intermediate representation to standard out.")
	var output: String?
	
	/// The highest intermediate language supported by Glyco.
	///
	/// Update this typealias whenever a higher language is added.
	private typealias HighestSupportedLanguage = AL
	
	/// Executes the command.
	mutating func run() throws {
		
		let environment = ProcessInfo.processInfo.environment
		let toolchainURL = environment["CHERITOOLCHAIN"].map(URL.init(fileURLWithPath:))
		let systemURL = environment["CHERISYSROOT"].map(URL.init(fileURLWithPath:))
		let configuration = CompilationConfiguration(target: .cheriBSD, toolchainURL: toolchainURL, systemURL: systemURL)
		
		let sourceURL = URL(fileURLWithPath: source)
		let sourceLanguage = sourceURL.pathExtension.uppercased()
		let sourceData = try Data(contentsOf: sourceURL)
		let outputURL = output.map(URL.init(fileURLWithPath:))
		
		if let language = language {
			let ir = try HighestSupportedLanguage.loweredProgramRepresentation(
				fromData:		sourceData,
				sourceLanguage:	sourceLanguage,
				targetLanguage:	language.uppercased(),
				configuration:	configuration
			)
			if let outputURL = outputURL {
				try ir.write(to: outputURL, atomically: false, encoding: .utf8)
				print("Exported \(language.uppercased()) representation to \(outputURL.absoluteString).")
			} else {
				print(ir)
			}
		} else {
			let elf = try HighestSupportedLanguage.elfFromProgram(
				fromData:		sourceData,
				sourceLanguage:	sourceLanguage,
				configuration:	configuration
			)
			if let outputURL = outputURL {
				try elf.write(to: outputURL)
				print("Exported ELF (\(elf.count) bytes) to \(outputURL.absoluteString).")
			} else {
				print("ELF is \(elf.count) bytes long. Re-run this command with the -o <file> option to save the ELF to disk.")
			}
		}
		
	}
	
}
