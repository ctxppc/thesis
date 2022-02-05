// Glyco © 2021–2022 Constantino Tsarouhas

extension FO {
	
	/// A datum source.
	public enum Source : Codable, Equatable {
		
		/// The operand is given value.
		case immediate(Int)
		
		/// The operand is to be retrieved from a given location.
		case location(Location)
		
	}
	
}
