// Glyco © 2021 Constantino Tsarouhas

public enum CD : Language {
	
	/// A program on an CD machine.
	public struct Program : Codable, GlycoKit.Program {
		
		/// The program's effect.
		public var effect: Effect
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			var context = Context()
			return .init(blocks: try effect.lowered(in: &context, entryLabel: .programEntry, previousEffects: [], exitLabel: .programExit))
		}
		
	}
	
	// See protocol.
	public typealias Lower = PR
	
	public typealias Frame = Lower.Frame
	public typealias Register = Lower.Register
	public typealias Source = Lower.Source
	
}
