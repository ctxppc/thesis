// Glyco © 2021–2022 Constantino Tsarouhas

extension SV {
	
	/// A program element that can be invoked by name.
	public struct Procedure : SimplyLowerable, Element {
		
		/// Creates a procedure with given name, locals, and effect.
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
			var context = SV.Context()
			return .init(name, in: try effect.lowered(in: &context))
		}
		
	}
	
}
