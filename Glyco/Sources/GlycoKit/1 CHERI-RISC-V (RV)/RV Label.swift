// Glyco © 2021–2022 Constantino Tsarouhas

extension RV {
	
	/// An identifier that can be used to jump execution to.
	public struct Label : RawCodable, ExpressibleByStringLiteral, Hashable {
		
		/// The program entry label.
		public static let programEntry = Self(rawValue: "main")
		
		/// The program exit label.
		public static let programExit = Self(rawValue: "_exit")
		
		// See protocol.
		public init(rawValue: String) {
			self.rawValue = rawValue
		}
		
		// See protocol.
		public init(stringLiteral: String) {
			self.init(rawValue: stringLiteral)
		}
		
		// See protocol.
		public let rawValue: String
		
	}
	
}
