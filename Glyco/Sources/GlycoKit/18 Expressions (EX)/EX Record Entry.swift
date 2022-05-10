// Glyco © 2021–2022 Constantino Tsarouhas

import Sisp

extension EX {
	
	public struct RecordEntry : Element {
		
		/// Creates a record entry with given value for a field with given name.
		public init(_ name: Field.Name, _ value: Value) {
			self.name = name
			self.value = value
		}
		
		/// The field name.
		public var name: Field.Name
		
		/// The value of the field named `name`.
		public var value: Value
		
	}
	
}
