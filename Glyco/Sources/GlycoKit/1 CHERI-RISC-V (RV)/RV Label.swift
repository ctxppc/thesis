// Glyco © 2021 Constantino Tsarouhas

extension RV {
	
	/// An identifier that can be used to jump execution to.
	public struct Label : Codable, RawRepresentable {
		
		/// The entry point label.
		public static let main = Self(rawValue: "main")
		
		// See protocol.
		public init(rawValue: String) {
			self.rawValue = rawValue
		}
		
		// See protocol.
		public let rawValue: String
		
	}
	
}
