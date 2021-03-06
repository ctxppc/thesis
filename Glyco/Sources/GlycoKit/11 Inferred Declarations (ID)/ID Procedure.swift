// Glyco © 2021–2022 Constantino Tsarouhas

extension ID {
	
	/// A program element that can be invoked by name.
	public struct Procedure : SimplyLowerable, Element {
		
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
			var context = ID.Context()
			let effect = try effect.lowered(in: &context)	// first get declarations into context
			return .init(name, locals: context.declarations, in: effect)
		}
		
	}
	
}
