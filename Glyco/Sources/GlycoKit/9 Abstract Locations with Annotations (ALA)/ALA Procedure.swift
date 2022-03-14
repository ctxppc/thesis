// Glyco © 2021–2022 Constantino Tsarouhas

extension ALA {
	
	/// A program element that can be invoked by name.
	public struct Procedure : Codable, Equatable, Optimisable {
		
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
		public mutating func optimise(configuration: CompilationConfiguration) throws -> Bool {
			var coalesced = false
			while let (removedLocation, retainedLocation) = effect.safelyCoalescableLocations() {
				coalesced = true
				locals.remove(.abstract(removedLocation))
				var analysis = Analysis()
				effect = try effect.coalescing(removedLocation, into: retainedLocation, declarations: locals, analysis: &analysis, configuration: configuration)
			}
			return coalesced
		}
		
		/// Lowers `self` to a procedure in the lower language.
		func lowered(configuration: CompilationConfiguration) throws -> Lower.Procedure {
			var context = ALA.Context(
				declarations:	locals,
				assignments:	try .init(declarations: locals, analysisAtScopeEntry: effect.analysisAtEntry),
				configuration:	configuration
			)
			return .init(name, in: try effect.lowered(in: &context))
		}
		
	}
	
}
