// Glyco © 2021–2022 Constantino Tsarouhas

extension OB {
	
	/// A value denoting the type of an object.
	public struct ObjectType : Equatable, Codable {
		
		/// Creates an object type with given initialiser, methods, and state record type.
		public init(initialiser: Constructor, methods: [Method], state stateRecordType: RecordType) {
			self.initialiser = initialiser
			self.methods = methods
			self.stateRecordType = stateRecordType
		}
		
		/// The initialiser for objects of this type.
		public var initialiser: Constructor
		
		/// The methods for objects of this type.
		public var methods: [Method]
		
		/// The record type for objects of this type.
		public var stateRecordType: RecordType
		
		/// The symbol of the function for the initialiser, as defined by in a `letType` value.
		func initialiserSymbol(typeName: TypeName) -> Lower.Symbol {
			"ob.\(typeName).init"
		}
		
	}
	
}
