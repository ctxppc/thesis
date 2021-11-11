// Glyco © 2021 Constantino Tsarouhas

extension RV {
	
	/// An identifier that can be used to jump execution to.
	public struct Label : Codable, RawRepresentable, Hashable {
		
		/// The program entry label.
		public static let programEntry = Self(rawValue: "main")
		
		/// The program exit label.
		public static let programExit = Self(rawValue: "_exit")
		
		// See protocol.
		public init(rawValue: String) {
			self.rawValue = rawValue
		}
		
		// See protocol.
		public let rawValue: String
		
	}
	
}
