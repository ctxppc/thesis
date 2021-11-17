// Glyco © 2021 Constantino Tsarouhas

extension PC {
	
	/// A program element that can be called by name with zero or more arguments and that returns a result to the caller.
	public enum Procedure : Codable, Equatable {
		
		/// A procedure that performs `body` when invoked using `name` and arguments corresponding to `parameters`.
		case procedure(name: Label, parameters: [Location], body: Statement)
		
	}
	
}
