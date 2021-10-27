// Glyco © 2021 Constantino Tsarouhas

extension RV {
	
	/// A value denoting the type of a datum.
	public enum DataType : String, Codable {
		
		/// A 4-byte integer.
		case word
		
		/// An 8-byte capability.
		case capability
		
	}
	
}
