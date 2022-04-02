// Glyco © 2021–2022 Constantino Tsarouhas

extension OB {
	
	/// A value used while lowering.
	public struct TypeDefinition : Named, Codable, Equatable, SimplyLowerable {
		
		/// Creates a definition with given name and value type.
		public init(_ name: TypeName, _ type: ValueType) {
			self.name = name
			self.type = type
		}
		
		/// The defined name.
		public var name: TypeName
		
		/// The definition's type.
		public var type: ValueType
		
		// See protocol.
		func lowered(in context: inout ()) throws -> Lower.TypeDefinition {
			.init(name, try type.lowered(in: &context))
		}
		
	}
	
}
