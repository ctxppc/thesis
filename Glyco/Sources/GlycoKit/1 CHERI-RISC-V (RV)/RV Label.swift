// Glyco © 2021–2022 Constantino Tsarouhas

extension RV {
	
	/// An identifier that can be used to jump execution to.
	public struct Label : Name, RawCodable {
		
		/// The label for the initialisation routine.
		public static let initialise: Self = "rv.init"
		
		/// The label for the user program's first instruction.
		public static let programEntry: Self = "rv.main"
		
		/// The label for the exit routine.
		public static let programExit: Self = "_exit"
		
		// See protocol.
		public init(rawValue: String) {
			self.rawValue = rawValue
		}
		
		// See protocol.
		public let rawValue: String
		
	}
	
}
