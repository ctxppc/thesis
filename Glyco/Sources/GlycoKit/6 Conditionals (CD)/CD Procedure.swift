// Glyco © 2021–2022 Constantino Tsarouhas

extension CD {
	
	/// A program element that can be invoked by name.
	public struct Procedure : Codable, Equatable, MultiplyLowerable {
		
		public init(_ name: Label, _ effect: Effect) {
			self.name = name
			self.effect = effect
		}
		
		/// The name with which the procedure can be invoked.
		public var name: Label
		
		/// The procedure's effect when invoked.
		public var effect: Effect
		
		// See protocol.
		func lowered(in context: inout Context) throws -> [Lower.Block] {
			try effect
				.flattened()
				.optimised()
				.lowered(in: &context, entryLabel: name, previousEffects: [], exitLabel: .programExit)
		}
		
	}
	
}
