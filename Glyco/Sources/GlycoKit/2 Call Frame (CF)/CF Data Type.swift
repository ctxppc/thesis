// Glyco © 2021–2022 Constantino Tsarouhas

extension CF {
	
	/// A value denoting the type of a datum.
	///
	/// Data types are only introduced in CF because RV doesn't have a uniform interface dealing with arbitrary data types, e.g., there's no single instruction for copying a byte and the load/store instructions differ in format between capabilities and non-capabilities.
	public enum DataType : String, Equatable, Codable {
		
		/// An unsigned byte or 1-byte integer.
		case byte
		
		/// A signed 4-byte integer.
		case signedWord
		
		/// An 8-byte capability.
		case capability
		
		/// The size of a datum of this type, in bytes.
		public var byteSize: Int {
			switch self {
				case .byte:			return 1
				case .signedWord:	return 4
				case .capability:	return 8
			}
		}
		
	}
	
}
