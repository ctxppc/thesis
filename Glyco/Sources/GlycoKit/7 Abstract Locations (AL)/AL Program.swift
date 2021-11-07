// Glyco © 2021 Constantino Tsarouhas

public enum AL : Language {
	
	/// A program on an AL machine.
	public struct Program : Codable, GlycoKit.Program {
		
		/// Creates a program with given effect.
		public init(effect: Effect) {
			self.effect = effect
		}
		
		/// The program's effect.
		public var effect: Effect
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) -> Lower.Program {
			var context = Context(assignments: .init(conflicts: effect.conflicts()))
			return .init(effect: effect.lowered(in: &context))
		}
		
	}
	
	// See protocol.
	public typealias Lower = CD
	
}
