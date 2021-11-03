// Glyco © 2021 Constantino Tsarouhas

public enum CD : Language {
	
	/// A program on an CD machine.
	public struct Program : Codable, GlycoKit.Program {
		
		/// The program's effect.
		public var effect: Effect
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) -> Lower.Program {
			var context = Context()
			return .init(blocks: effect.lowered(in: &context, entryLabel: .entry, previousEffects: []))
		}
		
	}
	
	// See protocol.
	public typealias Lower = PR
	
	public typealias Frame = Lower.Frame
	public typealias Source = Lower.Source
	
}
