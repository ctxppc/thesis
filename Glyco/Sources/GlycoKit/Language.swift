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
	
	/// Lowers a representation `sispString` of a program in a language named `sourceLanguage` to a representation in a lower language named `targetLanguage`.
	static func loweredProgramRepresentation(fromSispString sispString: String, sourceLanguage: String, targetLanguage: String, configuration: CompilationConfiguration) throws -> String
	
	/// Lowers `program` to a representation in a lower language named `targetLanguage`.
	static func loweredProgramRepresentation(_ program: Program, targetLanguage: String, configuration: CompilationConfiguration) throws -> String
	
	/// Lowers a representation `sispString` of a program in a language named `sourceLanguage` to S, encodes it into an object, and links it into an ELF executable.
	static func elfFromProgram(fromSispString sispString: String, sourceLanguage: String, configuration: CompilationConfiguration) throws -> Data
	
}

// Never is a bottom type so this conformance grounds Language.
extension Never : Language {
	public typealias Program = Self
	public typealias Lower = Self
}

extension Language {
	
	public static func loweredProgramRepresentation(fromSispString sispString: String, sourceLanguage: String, targetLanguage: String, configuration: CompilationConfiguration) throws -> String {
		if isNamed(sourceLanguage) {
			let program = try SispDecoder(from: sispString).decode(Program.self)
			return try loweredProgramRepresentation(program, targetLanguage: targetLanguage, configuration: configuration)
		} else {
			return try Lower.loweredProgramRepresentation(
				fromSispString:	sispString,
				sourceLanguage:	sourceLanguage,
				targetLanguage:	targetLanguage,
				configuration:	configuration
			)
		}
	}
	
	public static func loweredProgramRepresentation(_ program: Program, targetLanguage: String, configuration: CompilationConfiguration) throws -> String {
		if isNamed(targetLanguage) {
			return try SispEncoder().encode(program).serialised()
		} else {
			return try Lower.loweredProgramRepresentation(
				program.lowered(configuration: configuration),
				targetLanguage:	targetLanguage,
				configuration:	configuration
			)
		}
	}
	
	public static func elfFromProgram(fromSispString sispString: String, sourceLanguage: String, configuration: CompilationConfiguration) throws -> Data {
		if isNamed(sourceLanguage) {
			let program = try SispDecoder(from: sispString).decode(Program.self)
			return try program.elf(configuration: configuration)
		} else {
			return try Lower.elfFromProgram(fromSispString: sispString, sourceLanguage: sourceLanguage, configuration: configuration)
		}
	}
	
	/// Returns a Boolean value indicating whether `Self` is named `name`.
	static func isNamed(_ name: String) -> Bool {
		"\(self)" == name
	}
	
}
