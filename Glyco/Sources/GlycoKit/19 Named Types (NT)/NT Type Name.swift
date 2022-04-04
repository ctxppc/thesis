// Glyco © 2021–2022 Constantino Tsarouhas

extension NT {
	public struct TypeName : Name {
		
		// See protocol.
		public init(rawValue: String) {
			self.rawValue = rawValue
		}
		
		/// The name.
		public var rawValue: String
		
	}
}
