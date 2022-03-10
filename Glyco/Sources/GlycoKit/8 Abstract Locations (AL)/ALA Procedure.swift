// Glyco © 2021–2022 Constantino Tsarouhas

extension ALA {
	
	/// A program element that can be invoked by name.
	public struct Procedure : Codable, Equatable, SimplyLowerable, Optimisable {
		
		/// Creates a procedure with given name, locals, and effect.
		public init(_ name: Label, locals: Declarations, in effect: Effect) {
			self.name = name
			self.locals = locals
			self.effect = effect
		}
		
		/// The name with which the procedure can be invoked.
		public var name: Label
		
		/// The declared locations.
		public var locals: Declarations
		
		/// The procedure's effect when invoked.
		public var effect: Effect
		
		// See protocol.
		public mutating func optimise() throws -> Bool {
			var coalesced = false
			while let (removedLocation, retainedLocation) = effect.safelyCoalescableLocations() {
				coalesced = true
				locals.remove(.abstract(removedLocation))
				var analysis = Analysis()
				effect = try effect.coalescing(removedLocation, into: retainedLocation, declarations: locals, analysis: &analysis)
			}
			return coalesced
		}
		
		// See protocol.
		func lowered(in context: inout ()) throws -> Lower.Procedure {	// procedures don't take a context
			var context = ALA.Context(
				declarations:	locals,
				assignments:	try .init(declarations: locals, analysisAtScopeEntry: effect.analysisAtEntry)
			)
			return .init(name, in: try effect.lowered(in: &context))
		}
		
	}
	
}