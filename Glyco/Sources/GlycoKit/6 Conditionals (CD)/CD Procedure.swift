// Glyco © 2021–2022 Constantino Tsarouhas

extension CD {
	
	/// A program element that can be invoked by name.
	public struct Procedure : Codable, Equatable, Named, MultiplyLowerable, Optimisable {
		
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
		func lowered(in context: inout Context) throws -> [Lower.Block] {
			try effect.lowered(in: &context, entryLabel: name, previousEffects: [], exitLabel: .programExit)
		}
		
		// See protocol.
		public mutating func optimise() throws -> Bool {
			try effect.optimise()
		}
		
	}
	
}
