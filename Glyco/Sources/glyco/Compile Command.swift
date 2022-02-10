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
	
	Pass -O to output the programs in the specified intermediate languages to standard out. Pass -o to write the programs in the specified intermediate languages or the binary to disk. The -o option accepts paths relative to the current directory, one path per corresponding intermediate language or one path for the ELF binary. For any language for which no corresponding path is defined or if -o is omitted, a filename is derived from the source file and the file is stored in the same directory as the source file. Any files specified with or derived by -o are overwritten.
	"""
	
	@Argument(help: "A Gly or intermediate file, relative to the current directory. The file‘s extension must be .gly or the name of an intermediate language: .S, .rv, .fl, etc.")
	var source: URL
	
	@Option(name: .shortAndLong, parsing: .upToNextOption, help: "The intermediate languages (S, FL, FO, etc.) to emit. (Omit to build an ELF file.)")
	var languages: [String] = []
	
	@Option(name: .shortAndLong, help: "The target to build for. Choose between \(CompilationConfiguration.Target.sail) and \(CompilationConfiguration.Target.cheriBSD).")
	var target: CompilationConfiguration.Target = .sail
	
	@Option(name: [.short, .customLong("output")], parsing: .upToNextOption, help: "Output programs to disk at specified locations, to be overwritten and relative to the current directory. (Omit to write in the source file‘s directory.)")
	var outputURLs: [URL] = []
	
	@Flag(name: [.customShort("O"), .long], help: "Output intermediate programs to standard out.")
	var outputsToStandardOut: Bool = false
	
	@Option(name: .shortAndLong, parsing: .upToNextOption, help: "The registers to use for passing arguments, in parameter order.")
	var argumentRegisters: [AL.Register] = AL.Register.defaultArgumentRegisters
	
	@Flag(name: .long, inversion: .prefixedNo, help: "Enable/disable intra-language optimisations.")
	var optimise: Bool = true
	
	@Flag(name: .long, inversion: .prefixedNo, help: "Enable/disable intra-language validations.")
	var validate: Bool = true
	
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
			argumentRegisters:	argumentRegisters,
			optimise:			optimise,
			validate:			validate
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
		if languages.isEmpty {
			
			let elf = try HighestSupportedLanguage.elfFromProgram(
				fromSispString:	sourceString,
				sourceLanguage:	sourceLanguage,
				configuration:	configuration
			)
			if let outputURL = outputURLs.first {
				try elf.write(to: outputURL)
				print("Exported ELF (\(elf.count) bytes) to \(outputURL.absoluteString).")
			} else {
				print("The ELF executable is \(elf.count) bytes long. Re-run this command with the -o flag or -O <file> option to save the binary to disk.")
			}
			
		} else {
			
			let normalisedLanguageNames = languages.map { $0.uppercased() }
			let urlsByLanguage = Dictionary(uniqueKeysWithValues: zip(normalisedLanguageNames, outputURLs))
			let programsByLanguage = try HighestSupportedLanguage.loweredProgramRepresentation(
				fromSispString:		sourceString,
				sourceLanguage:		sourceLanguage,
				targetLanguages:	.init(normalisedLanguageNames),
				configuration:		configuration
			)
			
			for (language, program) in programsByLanguage {
				let url = urlsByLanguage[language] ?? derivedOutputURL(language: language)
				try program.write(to: url, atomically: false, encoding: .utf8)
				print("Exported \(language.uppercased()) program to \(url.absoluteString).")
			}
			
			if outputsToStandardOut {
				for language in normalisedLanguageNames {
					print("<language name='\(language)'><![CDATA[")
					print(programsByLanguage[language]!)
					print("]]></language>")
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

extension AL.Register : ExpressibleByArgument {
	public init?(argument: String) {
		self.init(rawValue: argument)
	}
}
