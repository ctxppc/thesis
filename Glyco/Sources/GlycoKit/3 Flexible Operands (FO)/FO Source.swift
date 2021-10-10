// Glyco © 2021 Constantino Tsarouhas

/// A datum source.
enum FOSource : Codable {
	
	/// The operand is to be retrieved from a given location.
	case location(FOLocation)
	
	/// The operand is a given value.
	case immediate(Int)
	
}

typealias FOLocation = FLLocation
