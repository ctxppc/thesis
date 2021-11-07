// Glyco © 2021 Constantino Tsarouhas

extension AL {
	
	/// A partition of locations into either possibly alive or definitely dead between the execution of an effect and its successor.
	struct LivenessSet : Codable {
		
		/// A liveness set where every location's value is definitely not used by a successor.
		static let nothingUsed = Self()
		
		/// The locations whose values are possibly used by a successor.
		private(set) var possiblyAliveLocations: Set<Location> = []
		
		subscript (location: Location) -> Usage {
			get { possiblyAliveLocations.contains(location) ? .possiblyUsedLater : .definitelyDiscarded }
			set {
				switch newValue {
					case .possiblyUsedLater:	possiblyAliveLocations.insert(location)
					case .definitelyDiscarded:	possiblyAliveLocations.remove(location)
				}
			}
		}
		
		enum Usage {
			
			/// The value is possibly used later.
			case possiblyUsedLater
			
			/// The value is definitely discarded.
			case definitelyDiscarded
			
		}
		
		/// Marks the possibly alive locations in `other` as possibly alive in `self`.
		mutating func formUnion(with other: Self) {
			self.possiblyAliveLocations.formUnion(other.possiblyAliveLocations)
		}
		
	}
	
}
