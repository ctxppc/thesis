// Glyco © 2021–2022 Constantino Tsarouhas

extension AL {
	
	/// A program element that can be invoked by name.
	public struct Procedure : Codable, Equatable {
		
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
		
		/// Lowers `self` to a procedure in the lower language.
		func lowered(configuration: CompilationConfiguration) throws -> Lower.Procedure {
			var analysis = Lower.Analysis()
			return .init(
				name,
				locals:	locals,
				in:		try effect.lowered().updated(using: Lower.Identity(), analysis: &analysis, configuration: configuration)
			)
		}
		
	}
	
}
