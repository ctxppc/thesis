// Glyco © 2021–2022 Constantino Tsarouhas

import Sisp

extension CL {
	
	public struct RecordEntry : SimplyLowerable, Element {
		
		/// Creates a record entry with given value for a field with given name.
		public init(_ name: Field.Name, _ value: Value) {
			self.name = name
			self.value = value
		}
		
		/// The field name.
		public var name: Field.Name
		
		/// The value of the field named `name`.
		public var value: Value
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.RecordEntry {
			.init(name, try value.lowered(in: &context))
		}
		
	}
	
}
