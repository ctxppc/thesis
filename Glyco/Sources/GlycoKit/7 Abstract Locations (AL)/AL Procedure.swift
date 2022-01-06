// Glyco © 2021–2022 Constantino Tsarouhas

extension AL {
	
	/// A program element that can be invoked by name.
	public struct Procedure : Codable, Equatable, SimplyLowerable {
		
		public init(_ name: Label, _ effect: Effect) {
			self.name = name
			self.effect = effect
		}
		
		/// The name with which the procedure can be invoked.
		public var name: Label
		
		/// The procedure's effect when invoked.
		public var effect: Effect
		
		// See protocol.
		func lowered(in context: inout GlobalContext) throws -> Lower.Procedure {
			let (_, conflicts) = effect.livenessAndConflictsAtEntry(livenessAtExit: .nothingUsed, conflictsAtExit: .conflictFree)
			var context = AL.LocalContext(assignments: .init(conflicts: conflicts))
			return .init(name, try effect.lowered(in: &context))
		}
		
	}
	
}
