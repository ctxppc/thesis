// Glyco © 2021–2022 Constantino Tsarouhas

extension AL {
	
	/// A program element that can be invoked by name.
	public struct Procedure : Codable, Equatable, SimplyLowerable {
		
		/// Creates a procedure with given name and effect.
		public init(_ name: Label, in effect: Effect) {
			self.name = name
			self.effect = effect
		}
		
		/// The name with which the procedure can be invoked.
		public var name: Label
		
		/// The procedure's effect when invoked.
		public var effect: Effect
		
		// See protocol.
		func lowered(in context: inout ()) throws -> Lower.Procedure {
			var analysis = Lower.Analysis()
			return .init(name, in: try effect.lowered().updated(using: { $0 }, analysis: &analysis))
		}
		
	}
	
}
