// Glyco © 2021–2022 Constantino Tsarouhas

extension PA {
	
	/// A program element that can be invoked by name.
	public struct Procedure : Codable, Equatable, SimplyLowerable {
		
		public init(_ name: Label, _ parameters: [Parameter], _ effect: Effect) {
			self.name = name
			self.parameters = parameters
			self.effect = effect
		}
		
		/// The name with which the procedure can be invoked.
		public var name: Label
		
		/// The procedure's parameters.
		public var parameters: [Parameter]
		
		/// The procedure's effect when invoked.
		var effect: Effect
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Procedure {
			.init(name, try effect.lowered(in: &context))
		}
		
	}
	
}
