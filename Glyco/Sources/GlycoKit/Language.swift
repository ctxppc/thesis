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
	
	/// Lowers a representation `sispString` of a program in a language named `sourceLanguage` to representations in lower languages named in `targetLanguages`.
	static func loweredProgramRepresentation(fromSispString sispString: String, sourceLanguage: String, targetLanguages: Set<String>, configuration: CompilationConfiguration) throws -> [String : String]
	
	/// Lowers `program` to representations in lower languages named in `targetLanguages`.
	static func loweredProgramRepresentation(_ program: Program, targetLanguages: Set<String>, configuration: CompilationConfiguration) throws -> [String : String]
	
	/// Lowers a representation `sispString` of a program in a language named `sourceLanguage` to S, encodes it into an object, and links it into an ELF executable.
	static func elfFromProgram(fromSispString sispString: String, sourceLanguage: String, configuration: CompilationConfiguration) throws -> Data
	
}

// Never is a bottom type so this conformance grounds Language.
extension Never : Language {
	public typealias Program = Self
	public typealias Lower = Self
}

extension Language {
	
	public static func loweredProgramRepresentation(fromSispString sispString: String, sourceLanguage: String, targetLanguages: Set<String>, configuration: CompilationConfiguration) throws -> [String : String] {
		if sourceLanguage == self.name {
			let program = try SispDecoder(from: sispString).decode(Program.self)
			return try loweredProgramRepresentation(program, targetLanguages: targetLanguages, configuration: configuration)
		} else {
			return try Lower.loweredProgramRepresentation(
				fromSispString:		sispString,
				sourceLanguage:		sourceLanguage,
				targetLanguages:	targetLanguages,
				configuration:		configuration
			)
		}
	}
	
	public static func loweredProgramRepresentation(_ program: Program, targetLanguages: Set<String>, configuration: CompilationConfiguration) throws -> [String : String] {
		
		if targetLanguages.isEmpty {
			return [:]
		}
		
		var targetLanguages = targetLanguages
		let encodedTargetProgram = targetLanguages.remove(name) != nil
			? try SispEncoder().encode(program).serialised()
			: nil
		
		var loweredPrograms = try Lower.loweredProgramRepresentation(
			program.processedLowering(configuration: configuration),
			targetLanguages:	targetLanguages,
			configuration:		configuration
		)
		
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
