// Glyco © 2021–2022 Constantino Tsarouhas

extension PR {
	
	/// A sequence of effects with a single entry and exit point.
	public struct Block : Codable, Equatable, SimplyLowerable {
		
		/// Creates a block with given label, effects, and continuation.
		public init(label: Label, do effects: [Effect], then continuation: Continuation) {
			self.label = label
			self.effects = effects
			self.continuation = continuation
		}
		
		/// The block's label.
		public var label: Label
		
		/// The block's effects.
		public var effects: [Effect]
		
		/// The action to take after executing `effects`.
		public var continuation: Continuation
		
		// See protocol.
		public func lowered(in context: inout Context) throws -> Lower.Block {
			.init(label: label, do: effects, then: continuation.lowered(in: &context))
		}
		
	}
	
}
