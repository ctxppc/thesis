// Glyco © 2021 Constantino Tsarouhas

/// A language that introduces structural value expressions, thereby abstracting over simple computation effects.
public enum EX : Language {
	
	/// A program on an EX machine.
	public struct Program : Codable, GlycoKit.Program {
		
		/// Creates a program with given body.
		public init(body: Statement) {
			self.body = body
		}
		
		/// The program's body.
		public var body: Statement
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			var context = Context()
			return .init(effect: try body.lowered(in: &context))
		}
		
	}
	
	// See protocol.
	public typealias Lower = AL
	
	public typealias Label = Lower.Label
	public typealias Location = Lower.Location
	public typealias Predicate = Lower.Predicate
	
}
