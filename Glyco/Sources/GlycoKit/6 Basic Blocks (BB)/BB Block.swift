// Glyco © 2021–2022 Constantino Tsarouhas

import DepthKit

extension BB {
	
	/// A sequence of effects with a single entry and exit point.
	public struct Block : Named, Element {
		
		/// Creates a block with given name, effects, and continuation.
		public init(name: Label, do effects: [Effect], then continuation: Continuation) {
			self.name = name
			self.effects = effects
			self.continuation = continuation
		}
		
		// See protocol.
		public var name: Label
		
		/// The block's effects.
		public var effects: [Effect]
		
		/// The action to take after executing `effects`.
		public var continuation: Continuation
		
	}
	
}
