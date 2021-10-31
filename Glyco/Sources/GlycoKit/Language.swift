// Glyco © 2021 Constantino Tsarouhas

import Foundation
import Yams

public protocol Language {
	
	/// A program.
	associatedtype Program : GlycoKit.Program where Program.LowerProgram == Lower.Program
	
	/// The lower language.
	associatedtype Lower : Language
	
	/// Lowers a representation `data` of a program in a language named `sourceLanguage` to a representation in a lower language named `targetLanguage`.
	static func loweredProgramRepresentation(fromData data: Data, sourceLanguage: String, targetLanguage: String, configuration: CompilationConfiguration) throws -> String
	
	/// Lowers `program` to a representation in a lower language named `targetLanguage`.
	static func loweredProgramRepresentation(_ program: Program, targetLanguage: String, configuration: CompilationConfiguration) throws -> String
	
	/// Lowers a representation `data` of a program in a language named `sourceLanguage` to S, encodes it into an object, and links it into an ELF executable.
	static func elfFromProgram(fromData data: Data, sourceLanguage: String, configuration: CompilationConfiguration) throws -> Data
	
}

extension Never : Language {
	public typealias Program = Self
	public typealias Lower = Self
}

extension Language {
	
	/// Lowers a representation `data` of a program in a language named `sourceLanguage` to a representation in a lower language named `targetLanguage`.
	public static func loweredProgramRepresentation(fromData data: Data, sourceLanguage: String, targetLanguage: String, configuration: CompilationConfiguration) throws -> String {
		if isNamed(sourceLanguage) {
			let program = try YAMLDecoder().decode(Program.self, from: data)
			return try loweredProgramRepresentation(program, targetLanguage: targetLanguage, configuration: configuration)
		} else {
			return try Lower.loweredProgramRepresentation(
				fromData:		data,
				sourceLanguage:	sourceLanguage,
				targetLanguage:	targetLanguage,
				configuration:	configuration
			)
		}
	}
	
	/// Lowers `program` to a representation in a lower language named `targetLanguage`.
	public static func loweredProgramRepresentation(_ program: Program, targetLanguage: String, configuration: CompilationConfiguration) throws -> String {
		if isNamed(targetLanguage) {
			return try YAMLEncoder().encode(program)
		} else {
			return try Lower.loweredProgramRepresentation(
				program.lowered(configuration: configuration),
				targetLanguage:	targetLanguage,
				configuration:	configuration
			)
		}
	}
	
	/// Lowers a representation `data` of a program in a language named `sourceLanguage` to S, encodes it into an object, and links it into an ELF executable.
	public static func elfFromProgram(fromData data: Data, sourceLanguage: String, configuration: CompilationConfiguration) throws -> Data {
		if isNamed(sourceLanguage) {
			let program = try YAMLDecoder().decode(Program.self, from: data)
			return try program.elf(configuration: configuration)
		} else {
			return try Lower.elfFromProgram(fromData: data, sourceLanguage: sourceLanguage, configuration: configuration)
		}
	}
	
	/// Returns a Boolean value indicating whether `Self` is named `name`.
	static func isNamed(_ name: String) -> Bool {
		"\(self)" == name
	}
	
}
