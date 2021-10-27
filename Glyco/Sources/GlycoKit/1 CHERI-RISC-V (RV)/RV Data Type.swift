// Glyco © 2021 Constantino Tsarouhas

extension RV {
	
	/// A value denoting the type of a datum.
	public enum DataType : String, Codable {
		
		/// A 4-byte integer.
		case word
		
		/// An 8-byte capability.
		case capability
		
		/// The size of a datum of this type, in bytes.
		public var byteSize: Int {
			switch self {
				case .word:			return 4
				case .capability:	return 8
			}
		}
		
	}
	
}
