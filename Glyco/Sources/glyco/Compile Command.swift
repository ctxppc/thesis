// Glyco © 2021–2022 Constantino Tsarouhas

import ArgumentParser
import DepthKit
import Foundation
import GlycoKit
#if os(macOS)
import KZFileWatchers
#endif

@main
struct CompileCommand : ParsableCommand {
	
	// See protocol.
	static let configuration = CommandConfiguration(commandName: "glyco", abstract: "Compiles Gly source files to CHERI-RISC-V executables.", discussion: discussion)
	
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
	var argumentRegisters: [AL.Register] = AL.Register.defaultArgumentRegisters
	
	#if os(macOS)
	@Flag(name: .shortAndLong, help: "Continuously observe source file for changes and compile. (Omit to compile once and exit.)")
	var continuous: Bool = false
	#endif
	
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
		
		#if os(macOS)
		if continuous {
			
			let watcher = FileWatcher.Local(path: source.absoluteURL.path)
			fileWatcher = watcher
			try watcher.start { [c = self] result in
				guard case .updated(data: let sourceData) = result else { return }
				c.compileAfterChange(sourceData: sourceData, configuration: configuration, sourceLanguage: sourceLanguage)
			}
			
			print("Observing \(source.absoluteURL.path)…")
			dispatchMain()
			
		} else {
			try compile(sourceString: try .init(contentsOf: source), configuration: configuration, sourceLanguage: sourceLanguage)
		}
		#else
		try compile(sourceString: try .init(contentsOf: source), configuration: configuration, sourceLanguage: sourceLanguage)
		#endif
		
	}
	
	private func compile(sourceString: String, configuration: CompilationConfiguration, sourceLanguage: String) throws {
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
	
	private func compileAfterChange(sourceData: Data, configuration: CompilationConfiguration, sourceLanguage: String) {
		do {
			guard let source = String(bytes: sourceData, encoding: .utf8) else { throw DecodingError.illegalUTF8 }
			try compile(sourceString: source, configuration: configuration, sourceLanguage: sourceLanguage)
		} catch {
			print(error)
		}
	}
	
	private enum DecodingError : Error {
		case illegalUTF8
	}
	
}

#if os(macOS)
private var fileWatcher: FileWatcher.Local?
#endif

extension CompilationConfiguration.Target : ExpressibleByArgument {}

extension AL.Register : ExpressibleByArgument {
	public init?(argument: String) {
		self.init(rawValue: argument)
	}
}
