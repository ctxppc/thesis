// Glyco © 2021–2022 Constantino Tsarouhas

/// A language that introduces structural value expressions, thereby abstracting over simple computation effects.
public enum EX : Language {
	
	/// A program on an EX machine.
	public struct Program : Codable, GlycoKit.Program {
		
		/// The program's main body.
		var body: Statement
		
		/// The program's procedures.
		var procedures: [Procedure]
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			var context = Context()
			return try .init(body.lowered(in: &context), procedures: procedures.lowered(in: &context))
		}
		
		// See protocol.
		public enum CodingKeys : String, CodingKey {
			case body = "_0"
			case procedures
		}
		
	}
	
	// See protocol.
	public typealias Lower = AL
	
	public typealias DataType = Lower.DataType
	public typealias Label = Lower.Label
	public typealias Location = Lower.Location
	public typealias Predicate = Lower.Predicate
	
}
