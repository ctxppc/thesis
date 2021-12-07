// Glyco © 2021 Constantino Tsarouhas

/// A language that introduces structural value expressions, thereby abstracting over simple computation effects.
public enum EX : Language {
	
	/// A program on an EX machine.
	public enum Program : Codable, GlycoKit.Program {
		
		/// A program with given body and procedures.
		case program(body: Statement, procedures: [Procedure])
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			switch self {
				case .program(let body, let procedures):
				var context = Context()
				return try .init(effect: body.lowered(in: &context), procedures: procedures.lowered(in: &context))
			}
		}
		
	}
	
	// See protocol.
	public typealias Lower = AL
	
	public typealias DataType = Lower.DataType
	public typealias Label = Lower.Label
	public typealias Location = Lower.Location
	public typealias Predicate = Lower.Predicate
	
}
