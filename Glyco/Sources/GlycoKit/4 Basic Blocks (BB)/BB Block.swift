// Glyco © 2021–2022 Constantino Tsarouhas

extension BB {
	
	/// A sequence of effects with a single entry and exit point.
	public struct Block : Codable, Equatable, MultiplyLowerable {
		
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
		public func lowered(in context: inout ()) throws -> [Lower.Effect] {
			switch continuation {
				
				case .continue(to: let successor):
				if let (first, tail) = try effects.lowered().splittingFirst() {
					return [.labelled(label, first)] + tail + [.jump(to: successor)]
				} else {
					return [.labelled(label, .jump(to: successor))]
				}
				
				case .branch(let lhs, let relation, let rhs, then: let affirmative, else: let negative):
				if let (first, tail) = try effects.lowered().splittingFirst() {
					return [.labelled(label, first)]
						+ tail
						+ [.branch(to: affirmative, lhs, relation, rhs), .jump(to: negative)]
				} else {
					return [.labelled(label, .branch(to: affirmative, lhs, relation, rhs)), .jump(to: negative)]
				}
				
				case .return:
				if let (first, tail) = try effects.lowered().splittingFirst() {
					return [.labelled(label, first)] + tail + [.return]
				} else {
					return [.labelled(label, .return)]
				}
				
			}
		}
		
	}
	
}
