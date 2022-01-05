// Glyco © 2021–2022 Constantino Tsarouhas

extension AL {
	
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
		public var effect: Effect
		
		// See protocol.
		func lowered(in context: inout GlobalContext) throws -> Lower.Procedure {
			let (_, conflicts) = effect.livenessAndConflictsAtEntry(livenessAtExit: .nothingUsed, conflictsAtExit: .conflictFree)
			var context = AL.LocalContext(
				assignments: .init(
					parameters:			parameters,
					conflicts:			conflicts,
					argumentRegisters:	context.configuration.argumentRegisters
				)
			)
			return .init(name, try parameters.lowered(in: &context), try effect.lowered(in: &context))
		}
		
	}
	
}
