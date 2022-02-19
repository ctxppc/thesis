// Glyco © 2021–2022 Constantino Tsarouhas

import DepthKit
import Foundation
import Sisp

extension Language {
	
	/// Lowers the program in a language named `sourceLanguage` and encoded in `sispString` to programs in `targetLanguages` and returns their encoded representations keyed by language name.
	public static func loweredProgramRepresentations(
		fromSispString sispString:	String,
		sourceLanguage:				String,
		targetLanguages: 			TargetLanguages,
		configuration:				CompilationConfiguration
	) throws -> [String : String] {
		try self.do(
			inLanguageNamed: sourceLanguage,
			DecodeSourceAndCollectLoweredRepresentationsAction(sispString: sispString, targetLanguages: targetLanguages, configuration: configuration)
		)
	}
	
}

private struct DecodeSourceAndCollectLoweredRepresentationsAction : LanguageAction {
	let sispString:	String
	let targetLanguages: TargetLanguages
	let configuration: CompilationConfiguration
	func callAsFunction<L : Language>(language: L.Type) throws -> [String : String] {
		let program = try SispDecoder(from: sispString).decode(L.Program.self)
		return try L.loweredProgramRepresentations(program, targetLanguages: targetLanguages, configuration: configuration)
	}
}

extension Language {
	
	/// Lowers `program` to programs in `targetLanguages` and returns their encoded representations keyed by language name.
	public static func loweredProgramRepresentations(
		_ program:			Program,
		targetLanguages:	TargetLanguages,
		configuration:		CompilationConfiguration
	) throws -> [String : String] {
		try reduce(program, using: LoweredRepresentationsReductor(targetLanguages: targetLanguages), configuration: configuration)
	}
	
}

public enum TargetLanguages {
	
	/// All languages.
	case all
	
	/// A given set of languages.
	case some(Set<String>)
	
	/// Removes `language` from `self` and returns a Boolean value indicating whether `language` was in `self`.
	fileprivate mutating func remove<L : Language>(_ language: L.Type) -> Bool {
		switch self {
			
			case .all:
			return true
			
			case .some(var names):
			let included = names.remove(language.name) != nil
			self = .some(names)
			return included
			
		}
	}
	
	/// A Boolean value indicating whether `self` is empty.
	fileprivate var isEmpty: Bool {
		switch self {
			case .all:				return false
			case .some(let names):	return names.isEmpty
		}
	}
	
}

private struct LoweredRepresentationsReductor : Reductor {
	
	init(targetLanguages: TargetLanguages) {
		self.targetLanguages = targetLanguages
	}
	
	private(set) var targetLanguages: TargetLanguages
	private var programSispsByLanguageName = Result()
	
	typealias Result = [String : String]
	
	mutating func update<L : Language>(language: L.Type, program: L.Program) throws -> Result? {
		if targetLanguages.remove(language) {
			programSispsByLanguageName[language.name] = try (program as? S.Program)?.assembly ?? SispEncoder().encode(program).serialised()
		}
		return targetLanguages.isEmpty ? programSispsByLanguageName : nil
	}
	
	func result() throws -> Result {
		programSispsByLanguageName
		// TODO: Print a warning if there are more target languages?
	}
	
}

extension Language {
	
	/// Lowers the program in a language named `sourceLanguage` and encoded in `sispString` to S, encodes it into an object, and links it into an ELF executable.
	public static func elfFromProgram(
		fromSispString sispString:	String,
		sourceLanguage:				String,
		configuration:				CompilationConfiguration
	) throws -> Data {
		try self.do(inLanguageNamed: sourceLanguage, DecodeSourceAndCompileELFAction(sispString: sispString, configuration: configuration))
	}
	
}

private struct DecodeSourceAndCompileELFAction : LanguageAction {
	let sispString:	String
	let configuration: CompilationConfiguration
	func callAsFunction<L : Language>(language: L.Type) throws -> Data {
		try L.reduce(
			SispDecoder(from: sispString).decode(L.Program.self),
			using:			CompileELFReductor(configuration: configuration),
			configuration:	configuration
		)
	}
}

private struct CompileELFReductor : Reductor {
	
	init(configuration: CompilationConfiguration) {
		self.configuration = configuration
	}
	
	let configuration: CompilationConfiguration
	private var elf: Data? = nil
	
	mutating func update<L : Language>(language: L.Type, program: L.Program) throws -> Data? {
		guard let program = program as? S.Program else { return nil }
		let elf = try program.elf(configuration: configuration)
		self.elf = elf
		return elf
	}
	
	func result() throws -> Data {
		elf !! "Reductor did not reach S"
	}
	
}
