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
	
	When one or more intermediate languages are specified with the -l option, Glyco lowers the source file to those languages. When no intermediate language is specified, Glyco lowers the source file to an ELF binary.
	
	By default, intermediate programs and binary executables are written to the same directory as the source file, with a filename derived from the source file. To change this, pass paths (relative to the current directory) using the -o option, one path per corresponding intermediate language or one path for the ELF binary. Glyco overwrites files.
	
	To disable writing to disk, pass the --stdout flag. Intermediate programs are written to standard out; binary executables are discarded after compilation.
	"""
	
	@Argument(help: "A Gly or intermediate file, relative to the current directory. The file‘s extension must be .gly or the name of an intermediate language: .s, .rv, .fl, etc.")
	var source: URL
	
	@Option(name: .shortAndLong, parsing: .upToNextOption, help: "The intermediate languages (S, FL, FO, etc.) to emit. (Omit to build an executable ELF file.)")
	var languages: [String] = []
	
	@Option(name: .shortAndLong, help: "The target to build for. Choose between \(CompilationConfiguration.Target.sail) and \(CompilationConfiguration.Target.cheriBSD).")
	var target: CompilationConfiguration.Target = .sail
	
	@Option(name: [.short, .customLong("output")], parsing: .upToNextOption, help: "Output programs to disk at specified locations, to be overwritten and relative to the current directory. (Omit to write in the source file‘s directory.)")
	var outputURLs: [URL] = []
	
	@Flag(name: .customLong("stdout"), help: "Output intermediate programs to standard out or discard binary. (Omit to write to disk.)")
	var outputsToStandardOut: Bool = false
	
	@Option(name: .customLong("cc"), help: "The calling convention to use. Choose between \(CompilationConfiguration.CallingConvention.conventional) and \(CompilationConfiguration.CallingConvention.heap).")
	var callingConvention: CompilationConfiguration.CallingConvention = .conventional
	
	@Option(name: .shortAndLong, parsing: .upToNextOption, help: "Registers used for passing arguments, in parameter order.")
	var argumentRegisters: [AL.Register] = AL.Register.argumentRegistersInRVABI
	
	@Flag(name: .long, inversion: .prefixedNo, help: "Enable/disable intra-language optimisations.")
	var optimise: Bool = true
	
	@Flag(name: .long, inversion: .prefixedNo, help: "Enable/disable intra-language validations.")
	var validate: Bool = true
	
	@Flag(name: .customLong("caller-saved-copying"), inversion: .prefixedNo, help: "Enable/disable caller-saved register copying around procedure calls to limit their lifetime.")
	var limitsCallerSavedRegisterLifetimes: Bool = true
	
	@Option(name: .customLong("line"), help: "The (suggested) maximum line length of output programs.")
	var maximumLineLength = 120
	
	#if os(macOS)
	@Flag(name: .shortAndLong, help: "Continuously observe source file for changes and compile. (Omit to compile once and exit.)")
	var continuous: Bool = false
	#endif
	
	// See protocol.
	mutating func run() throws {
		
		let environment = ProcessInfo.processInfo.environment
		let toolchainURL = environment["CHERITOOLCHAIN"].map(URL.init(fileURLWithPath:))
		let systemURL = environment["CHERISYSROOT"].map(URL.init(fileURLWithPath:))
		let configuration = with(CompilationConfiguration(target: target, toolchainURL: toolchainURL, systemURL: systemURL)) {
			$0.callingConvention = callingConvention
			$0.argumentRegisters = argumentRegisters
			$0.optimise = optimise
			$0.validate = validate
			$0.limitsCallerSavedRegisterLifetimes = limitsCallerSavedRegisterLifetimes
			$0.maximumLineLength = maximumLineLength
		}
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
		if languages.isEmpty {
			
			let elf = try HighestSupportedLanguage.elfFromProgram(
				fromSispString:	sourceString,
				sourceLanguage:	sourceLanguage,
				configuration:	configuration
			)
			
			if outputsToStandardOut {
				print("The ELF executable is \(elf.count) bytes long. Re-run this command without the --stdout flag to write the binary to disk.")
			} else {
				let outputURL = derivedOutputURL(language: nil)
				try elf.write(to: outputURL)
				print("Exported ELF (\(elf.count) bytes) to \(outputURL.absoluteString).")
			}
			
		} else {
			
			let normalisedLanguageNames = languages.map { $0.uppercased() }
			let urlsByLanguage = Dictionary(uniqueKeysWithValues: zip(normalisedLanguageNames, outputURLs))
			let programsByLanguage = try HighestSupportedLanguage.loweredProgramRepresentations(
				fromSispString:		sourceString,
				sourceLanguage:		sourceLanguage,
				targetLanguages:	.some(.init(normalisedLanguageNames)),
				configuration:		configuration
			)
			
			if outputsToStandardOut {
				for language in normalisedLanguageNames {
					guard let program = programsByLanguage[language] else { continue }
					print("<language name='\(language)'><![CDATA[")
					print(program)
					print("]]></language>")
				}
			} else {
				for (language, program) in programsByLanguage {
					let url = urlsByLanguage[language] ?? derivedOutputURL(language: language)
					try program.write(to: url, atomically: false, encoding: .utf8)
					print("Exported \(language.uppercased()) program to \(url.absoluteString).")
				}
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
	
	private func derivedOutputURL(language: String?) -> URL {
		let base = source
			.deletingLastPathComponent()
			.appendingPathComponent(
				source
					.deletingPathExtension()
					.lastPathComponent,
				isDirectory: false
			)
		return language.map { base.appendingPathExtension($0.lowercased()) } ?? base
	}
	
	private enum DecodingError : Error {
		case illegalUTF8
	}
	
}

#if os(macOS)
private var fileWatcher: FileWatcher.Local?
#endif

extension CompilationConfiguration.Target : ExpressibleByArgument {}
extension CompilationConfiguration.CallingConvention : ExpressibleByArgument {}

extension AL.Register : ExpressibleByArgument {
	public init?(argument: String) {
		self.init(rawValue: argument)
	}
}
