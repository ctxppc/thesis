// Glyco © 2021–2022 Constantino Tsarouhas

public protocol Validatable {
	
	/// Validates `self`.
	func validate(configuration: CompilationConfiguration) throws
	
}

extension MutableCollection where Element : Validatable {
	
	/// Validates the elements in `self`.
	func validate(configuration: CompilationConfiguration) throws {
		for element in self {
			try element.validate(configuration: configuration)
		}
	}
	
}
