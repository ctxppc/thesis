// Glyco © 2021 Constantino Tsarouhas

extension RV {
	
	/// An identifier that can be used to jump execution to.
	public struct Label : Codable, RawRepresentable {
		
		/// Allocates a new label, different from every other previously allocated label.
		public static func allocate(context: inout Context) -> Self {
			defer { context.numberOfAllocatedLabels += 1 }
			return Self(rawValue: "target\(context.numberOfAllocatedLabels)")
		}
		
		// See protocol.
		public init(rawValue: String) {
			self.rawValue = rawValue
		}
		
		// See protocol.
		public let rawValue: String
		
	}
	
}
