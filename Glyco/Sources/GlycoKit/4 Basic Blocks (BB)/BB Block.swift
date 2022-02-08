// Glyco © 2021–2022 Constantino Tsarouhas

extension BB {
	
	/// A sequence of effects with a single entry and exit point.
	public struct Block : Codable, Equatable, Named, MultiplyLowerable {
		
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
		
		// See protocol.
		public func lowered(in context: inout ()) throws -> [Lower.Effect] {
			switch continuation {
				
				case .continue(to: let successor):
				if let (first, tail) = try effects.lowered().splittingFirst() {
					return [.labelled(name, first)] + tail + [.jump(to: successor)]
				} else {
					return [.labelled(name, .jump(to: successor))]
				}
				
				case .branch(let lhs, let relation, let rhs, then: let affirmative, else: let negative):
				if let (first, tail) = try effects.lowered().splittingFirst() {
					return [.labelled(name, first)]
						+ tail
						+ [.branch(to: affirmative, lhs, relation, rhs), .jump(to: negative)]
				} else {
					return [.labelled(name, .branch(to: affirmative, lhs, relation, rhs)), .jump(to: negative)]
				}
				
				case .call(let name, returnPoint: let returnPoint):
				TODO.unimplemented
				
				case .return:
				if let (first, tail) = try effects.lowered().splittingFirst() {
					return [.labelled(name, first)] + tail + [.return]
				} else {
					return [.labelled(name, .return)]
				}
				
			}
		}
		
	}
	
}
