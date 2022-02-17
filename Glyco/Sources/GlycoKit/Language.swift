// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation
import Sisp

/// The highest intermediate language supported by GlycoKit.
///
/// Update this typealias whenever a higher language is added.
public typealias HighestSupportedLanguage = EX

public protocol Language {
	
	/// A program.
	associatedtype Program : GlycoKit.Program where Program.LowerProgram == Lower.Program
	
	/// The lower language.
	associatedtype Lower : Language
	
	/// Lowers a representation `sispString` of a program in a language named `sourceLanguage` to representations in lower languages named in `targetLanguages`, or to representations in all lower languages if `targetLanguages` is `nil`.
	static func loweredProgramRepresentations(fromSispString sispString: String, sourceLanguage: String, targetLanguages: Set<String>?, configuration: CompilationConfiguration) throws -> [String : String]
	
	/// Lowers `program` to representations in lower languages named in `targetLanguages`, or to representations in all lower languages if `targetLanguages` is `nil`.
	static func loweredProgramRepresentations(_ program: Program, targetLanguages: Set<String>?, configuration: CompilationConfiguration) throws -> [String : String]
	
	/// Lowers a representation `sispString` of a program in a language named `sourceLanguage` to S, encodes it into an object, and links it into an ELF executable.
	static func elfFromProgram(fromSispString sispString: String, sourceLanguage: String, configuration: CompilationConfiguration) throws -> Data
	
}

// Never is a bottom type so this conformance grounds Language.
extension Never : Language {
	public typealias Program = Self
	public typealias Lower = Self
}

extension Language {
	
	public static func loweredProgramRepresentations(fromSispString sispString: String, sourceLanguage: String, targetLanguages: Set<String>?, configuration: CompilationConfiguration) throws -> [String : String] {
		if sourceLanguage == self.name {
			let program = try SispDecoder(from: sispString).decode(Program.self)
			return try loweredProgramRepresentations(program, targetLanguages: targetLanguages, configuration: configuration)
		} else {
			return try Lower.loweredProgramRepresentations(
				fromSispString:		sispString,
				sourceLanguage:		sourceLanguage,
				targetLanguages:	targetLanguages,
				configuration:		configuration
			)
		}
	}
	
	public static func loweredProgramRepresentations(_ program: Program, targetLanguages: Set<String>?, configuration: CompilationConfiguration) throws -> [String : String] {
		
		let isTargetLanguage: Bool
		let remainingLanguages: Set<String>?
		let continueLowering: Bool
		if var targetLanguages = targetLanguages {
			isTargetLanguage = targetLanguages.remove(name) != nil
			remainingLanguages = targetLanguages
			continueLowering = !targetLanguages.isEmpty
		} else {
			isTargetLanguage = true
			remainingLanguages = nil
			continueLowering = true
		}
		
		let encodedTargetProgram = isTargetLanguage
			? try SispEncoder().encode(program).serialised()
			: nil
		
		var loweredPrograms: [String : String]
		
		if continueLowering {
			loweredPrograms = try Lower.loweredProgramRepresentations(
				program.processedLowering(configuration: configuration),
				targetLanguages:	remainingLanguages,
				configuration:		configuration
			)
		} else {
			loweredPrograms = [:]
		}
		
		loweredPrograms[name] = encodedTargetProgram
		
		return loweredPrograms
		
	}
	
	public static func elfFromProgram(fromSispString sispString: String, sourceLanguage: String, configuration: CompilationConfiguration) throws -> Data {
		if sourceLanguage == self.name {
			let program = try SispDecoder(from: sispString).decode(Program.self)
			return try program.elf(configuration: configuration)
		} else {
			return try Lower.elfFromProgram(fromSispString: sispString, sourceLanguage: sourceLanguage, configuration: configuration)
		}
	}
	
	/// The language's name.
	static var name: String { "\(self)" }
	
	typealias Bag<NameType : Name> = GlycoKit.Bag<NameType, Self>
	
}
