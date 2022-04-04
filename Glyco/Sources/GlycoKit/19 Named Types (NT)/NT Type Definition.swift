// Glyco © 2021–2022 Constantino Tsarouhas

extension NT {
	
	/// A definition of a named type.
	public struct TypeDefinition : Named, Codable, Equatable {
		
		/// Creates a definition with given name and value type.
		public init(_ name: TypeName, _ type: ValueType) {
			self.name = name
			self.type = type
		}
		
		/// The defined name.
		public var name: TypeName
		
		/// The definition's type.
		public var type: ValueType
		
	}
	
}
