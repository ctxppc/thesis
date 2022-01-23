// Glyco © 2021–2022 Constantino Tsarouhas

extension ALA {
	
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
		
		/// Optimises the procedure.
		public mutating func optimise() {
			while let (firstLocation, otherLocation) = effect.safelyCoalescableLocations() {
				var analysis = Analysis()
				effect = effect.coalescing(firstLocation, into: otherLocation, analysis: &analysis)
			}
		}
		
		// See protocol.
		func lowered(in context: inout ()) throws -> Lower.Procedure {	// procedures don't take a context
			var context = ALA.Context(assignments: .init(from: effect.analysisAtEntry))
			return .init(name, try effect.lowered(in: &context))
		}
		
	}
	
}
