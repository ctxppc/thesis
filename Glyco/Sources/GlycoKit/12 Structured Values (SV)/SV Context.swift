// Glyco © 2021–2022 Constantino Tsarouhas

extension SV {
	
	/// A value used while lowering a procedure.
	struct Context {
		
		/// A mapping from vector locations to element types.
		var elementTypesByVectorLocation = [Location : ValueType]()
		
		/// A mapping from record locations to record types.
		var recordTypesByRecordLocation = [Location : RecordType]()
		
		/// The locations containing sealed capabilities.
		var sealedLocations = Set<Location>()
		
		/// Returns a Boolean value indicating whether given location contains a sealed capability.
		///
		/// - Returns: `true` if `location` has most recently been marked as sealed; `false` if `location` has most recently been marked as unsealed or if its sealedness is unknown.
		func isSealed(_ location: Location) -> Bool {
			sealedLocations.contains(location)
		}
		
		/// Marks given location as containing a (un)sealed capability.
		mutating func mark(_ location: Location, asSealed sealed: Bool) {
			if sealed {
				sealedLocations.insert(location)
			} else {
				sealedLocations.remove(location)
			}
		}
		
		/// A bag of locations.
		var locations = Bag<AbstractLocation>()
		
	}
	
}
