// Glyco © 2021 Constantino Tsarouhas

/// A location to a frame cell on an FL machine.
struct FLFrameCellLocation : Codable {
	
	/// Allocates a new location, different from every other previously allocated location.
	static func allocate() -> Self {
		defer { sequenceNumber += 1 }
		return Self(identifier: sequenceNumber)
	}
	
	/// The number of locations generated.
	private static var sequenceNumber = 0
	
	/// Creates a location with given identifier.
	private init(identifier: Int) {
		self.identifier = identifier
	}
	
	/// The location's identifier.
	private let identifier: Int
	
}
