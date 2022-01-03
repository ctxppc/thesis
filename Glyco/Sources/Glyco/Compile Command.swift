// Glyco © 2021–2022 Constantino Tsarouhas

import ArgumentParser
import DepthKit
import Foundation
import GlycoKit

@main
struct CompileCommand : ParsableCommand {
	
	// See protocol.
	static let configuration = CommandConfiguration(commandName: "Glyco", abstract: "Compiles Gly source files to CHERI-RISC-V executables.", discussion: discussion)
	
	private static let discussion = """
	Glyco requires a CHERI-RISC-V toolchain and a CheriBSD system root, as built by cheribuild. The path to the toolchain can be provided through the CHERITOOLCHAIN environment variable; if omitted, Glyco assumes it‘s in ~/cheri. The path to the system root can be provided through the CHERISYSROOT environment variable; if omitted, Glyco assumes it‘s in output/rootfs-riscv64-purecap within the toolchain.
	"""
	
	@Argument(help: "A Gly or intermediate file. The file‘s extension must be .gly or the name of an intermediate language: .S, .rv, .fl, etc.")
	var source: URL
	
	@Option(name: .shortAndLong, help: "The intermediate language (S, FL, FO, etc.) to emit. (Omit to build an ELF file.)")
	var language: String?
	
	@Option(name: .shortAndLong, help: "The target to build for. Choose between \(CompilationConfiguration.Target.sail) and \(CompilationConfiguration.Target.cheriBSD).")
	var target: CompilationConfiguration.Target = .sail
	
	@Option(name: .shortAndLong, help: "The generated file (to be overwritten). (Omit to discard the ELF file after building it or to print the intermediate representation to standard out.)")
	var output: URL?
	
	@Option(name: .shortAndLong, parsing: .upToNextOption, help: "The argument registers to use in order. (Omit to use the standard RISC-V argument registers.)")
	var argumentRegisters: [FO.Register] = FO.Register.defaultArgumentRegisters
	
	/// The highest intermediate language supported by Glyco.
	///
	/// Update this typealias whenever a higher language is added.
	private typealias HighestSupportedLanguage = EX
	
	// See protocol.
	mutating func run() throws {
		
		let environment = ProcessInfo.processInfo.environment
		let toolchainURL = environment["CHERITOOLCHAIN"].map(URL.init(fileURLWithPath:))
		let systemURL = environment["CHERISYSROOT"].map(URL.init(fileURLWithPath:))
		let configuration = CompilationConfiguration(
			target:				target,
			toolchainURL:		toolchainURL,
			systemURL:			systemURL,
			argumentRegisters:	argumentRegisters
		)
		
		let sourceLanguage = source.pathExtension.uppercased()
		let sourceString = try String(contentsOf: source)
		
		if let language = language {
			let ir = try HighestSupportedLanguage.loweredProgramRepresentation(
				fromSispString:	sourceString,
				sourceLanguage:	sourceLanguage,
				targetLanguage:	language.uppercased(),
				configuration:	configuration
			)
			if let outputURL = output {
				try ir.write(to: outputURL, atomically: false, encoding: .utf8)
				print("Exported \(language.uppercased()) representation to \(outputURL.absoluteString).")
			} else {
				print(ir)
			}
		} else {
			let elf = try HighestSupportedLanguage.elfFromProgram(
				fromSispString:	sourceString,
				sourceLanguage:	sourceLanguage,
				configuration:	configuration
			)
			if let outputURL = output {
				try elf.write(to: outputURL)
				print("Exported ELF (\(elf.count) bytes) to \(outputURL.absoluteString).")
			} else {
				print("ELF is \(elf.count) bytes long. Re-run this command with the -o <file> option to save the ELF to disk.")
			}
		}
		
	}
	
}

extension CompilationConfiguration.Target : ExpressibleByArgument {}

extension FO.Register : ExpressibleByArgument {
	public init?(argument: String) {
		self.init(rawValue: argument)
	}
}
