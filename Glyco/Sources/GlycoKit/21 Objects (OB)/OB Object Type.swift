// Glyco © 2021–2022 Constantino Tsarouhas

extension OB {
	
	/// A value denoting the type of an object.
	public struct ObjectType : Equatable, Codable {
		
		/// Creates an object type with given initialiser, methods, and state record type.
		public init(initialiser: Initialiser, methods: [Method], state stateRecordType: RecordType) {
			self.initialiser = initialiser
			self.methods = methods
			self.stateRecordType = stateRecordType
		}
		
		/// The initialiser for objects of this type.
		public var initialiser: Initialiser
		
		/// The methods for objects of this type.
		public var methods: [Method]
		
		/// The record type for objects of this type.
		public var stateRecordType: RecordType
		
	}
	
}
