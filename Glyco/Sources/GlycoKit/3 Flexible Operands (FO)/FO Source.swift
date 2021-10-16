// Glyco © 2021 Constantino Tsarouhas

extension FO {
	
	/// A datum source.
	enum Source : Codable {
		
		/// The operand is to be retrieved from a given location.
		case location(Location)
		
		/// The operand is a given value.
		case immediate(Int)
		
	}
	
	typealias Location = FL.Location
	
}
