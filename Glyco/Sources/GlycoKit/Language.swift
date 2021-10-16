// Glyco © 2021 Constantino Tsarouhas

protocol Language {
	
	/// A program.
	associatedtype Program : GlycoKit.Program where Program.LowerProgram == Lower.Program
	
	/// The lower language.
	associatedtype Lower : Language
	
}

extension Never : Language {
	typealias Program = Self
	typealias Lower = Self
}
