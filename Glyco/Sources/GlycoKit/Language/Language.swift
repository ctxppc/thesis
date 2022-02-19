// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

/// The highest intermediate language supported by GlycoKit.
///
/// Update this typealias whenever a higher language is added.
public typealias HighestSupportedLanguage = EX

public protocol Language {
	
	/// A program.
	associatedtype Program : GlycoKit.Program where Program.LowerProgram == Lower.Program
	
	/// The lower language.
	associatedtype Lower : Language
	
	/// Performs `action` in a language named `name` that is either `Self` or a lower language of `Self`, and returns its result.
	static func `do`<Action : LanguageAction>(inLanguageNamed name: String, _ action: Action) throws -> Action.Result
	
	/// Reduces a sequence of lowered programs beginning with `program` using `reductor` and returns the reductor's result.
	static func reduce<R : Reductor>(_ program: Program, using reductor: R, configuration: CompilationConfiguration) throws -> R.Result
	
}

public protocol LanguageAction {
	func callAsFunction<L : Language>(language: L.Type) throws -> Result
	associatedtype Result
}

public protocol Reductor {
	
	/// The reductor's result.
	associatedtype Result
	
	/// Updates the reductor state given a language and program in that language.
	///
	/// - Returns: A result if the reduction is done, otherwise `nil`.
	mutating func update<L : Language>(language: L.Type, program: L.Program) throws -> Result?
	
	/// Determines a result or throws an error.
	///
	/// This method is invoked when the ground language has been reached.
	func result() throws -> Result
	
}

// Never is a bottom type so this conformance grounds Language.
extension Never : Language {
	
	public typealias Program = Self
	public typealias Lower = Self
	
	public static func `do`<Action : LanguageAction>(inLanguageNamed name: String, _ action: Action) throws -> Action.Result {
		throw LanguageError.unknownLanguage(name: name)
	}
	
}

enum LanguageError : LocalizedError {
	
	/// An error indicating that no language is known by given name.
	case unknownLanguage(name: String)
	
	// See protocol.
	var errorDescription: String? {
		switch self {
			case .unknownLanguage(name: let name):
			return "“\(name)” is not a language supported by Glyco."
		}
	}
	
}

extension Language {
	
	public static func `do`<Action : LanguageAction>(inLanguageNamed name: String, _ action: Action) throws -> Action.Result {
		try "\(Self.self)" == name ? action(language: self) : Lower.do(inLanguageNamed: name, action)
	}
	
	public static func reduce<R : Reductor>(_ program: Program, using reductor: R, configuration: CompilationConfiguration) throws -> R.Result {
		
		var program = program
		if configuration.optimise {
			try program.optimiseUntilFixedPoint()
		}
		if configuration.validate {
			try program.validate()
		}
		
		var reductor = reductor
		return try reductor.update(language: self, program: program)
			?? Lower.reduce(program.lowered(configuration: configuration), using: reductor, configuration: configuration)
		
	}
	
	/// The language's name.
	static var name: String { "\(self)" }
	
	/// A bag type suitable for use in `Self`.
	typealias Bag<NameType : Name> = GlycoKit.Bag<NameType, Self>
	
}
