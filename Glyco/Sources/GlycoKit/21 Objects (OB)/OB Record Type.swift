// Glyco © 2021–2022 Constantino Tsarouhas

extension OB {
	
	/// A value denoting the type of a record.
	public struct RecordType : Codable, Equatable, SimplyLowerable {
		
		/// Creates a record type with given fields.
		///
		/// - Parameter fields: The record type's fields.
		public init(_ fields: [Field]) {
			self.fields = fields
		}
		
		/// The fields.
		public var fields: [Field]
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.RecordType {
			.init(try fields.lowered(in: &context))
		}
		
	}
	
	/// A field of a record.
	public struct Field : Named, Codable, Equatable, SimplyLowerable {
		
		/// Creates a field with given name and value type.
		public init(_ name: Name, _ valueType: ValueType) {
			self.name = name
			self.valueType = valueType
		}
		
		/// The field's name.
		public var name: Name
		public typealias Name = Lower.Field.Name
		
		/// The value type of the field.
		public var valueType: ValueType
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Field {
			.init(name, try valueType.lowered(in: &context))
		}
		
	}
	
}
