// Glyco © 2021–2022 Constantino Tsarouhas

import DepthKit
import OrderedCollections

extension SV {
	
	/// A value denoting the type of a record.
	///
	/// Like vectors, records are always stored in memory and are created using allocation effects. Like vectors and unlike C structs, records are never implicitly copied in SV. Records can therefore not be assigned to or from a location, are always referred to by capability, and cannot directly contain other records.
	public struct RecordType : Equatable {
		
		/// Creates a record type with given fields.
		///
		/// - Parameter fields: The record type's fields, in order. Later fields override previous fields with the same name.
		public init(_ fields: [Field]) {
			for field in fields {
				appendOrReplace(field)
			}
		}
		
		/// An ordered mapping from field names to types.
		private var typesByFieldName = TypesByFieldName()
		typealias TypesByFieldName = OrderedDictionary<Field.Name, ValueType>
		
		/// Prepends `field` if `self` doesn't contain a field with the same name as `field`, or replaces the field in `self` with the same name as `field` by `field`.
		public mutating func prependOrReplace(_ field: Field) {
			typesByFieldName.updateValue(field.valueType, forKey: field.name, insertingAt: 0)
		}
		
		/// Appends `field` if `self` doesn't contain a field with the same name as `field`, or replaces the field in `self` with the same name as `field` by `field`.
		public mutating func appendOrReplace(_ field: Field) {
			typesByFieldName[field.name] = field.valueType
		}
		
		/// Returns the field named `name`, or `nil` if `self` doesn't such a field.
		public func field(named name: Field.Name) -> Field? {
			typesByFieldName[name]
				.map { .init(name: name, valueType: $0) }
		}
		
		/// Returns the byte offset of given field.
		///
		/// - Requires: `self` contains `field`.
		public func byteOffset(of field: Field) -> Int {
			let index = typesByFieldName.keys.firstIndex(of: field.name) !! "Expected field named “\(field.name)”"
			return self[..<index]
				.lazy
				.map(\.valueType.byteSize)
				.reduce(0, +)
		}
		
		public struct Field : Named, Equatable, Codable {
			
			/// The field's name.
			public var name: Name
			public struct Name : GlycoKit.Name {
				public init(rawValue: String) { self.rawValue = rawValue }
				public var rawValue: String
			}
			
			/// The value type of the field.
			public var valueType: ValueType
			
		}
		
		/// The number of bytes required to represent a record of type `self`.
		var byteSize: Int {
			typesByFieldName.elements.map(\.1.byteSize).reduce(0, +)
		}
		
		/// Returns a sequence of field–byte offset pairs.
		func fieldByteOffsetPairs() -> UnfoldSequence<(Field, offset: Int), (fields: TypesByFieldName.Elements.SubSequence, offset: Int)> {
			sequence(state: (fields: typesByFieldName.elements[...], offset: 0)) { state -> (Field, offset: Int)? in
				guard let (name, valueType) = state.fields.popFirst() else { return nil }
				defer { state.offset += valueType.byteSize }
				return (.init(name: name, valueType: valueType), state.offset)
			}
		}
		
	}
	
}

extension SV.RecordType : Codable {
	
	//sourcery: isInternalForm
	public init(from decoder: Decoder) throws {
		self.init(try decoder.singleValueContainer().decode([Field].self))
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(Array(self))
	}
	
}

extension SV.RecordType : RandomAccessCollection {
	
	public var startIndex: Int { typesByFieldName.elements.startIndex }
	
	public var endIndex: Int { typesByFieldName.elements.endIndex }
	
	public subscript (index: Int) -> Field {
		let (name, valueType) = typesByFieldName.elements[index]
		return .init(name: name, valueType: valueType)
	}
	
}
