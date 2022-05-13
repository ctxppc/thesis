// Glyco © 2021–2022 Constantino Tsarouhas

extension CL {
	
	/// A value denoting the type of an object.
	public struct ObjectType : Named, Element, SimplyLowerable {
		
		/// Creates an object type with given name, constructor, and methods.
		public init(_ name: TypeName, constructor: Constructor, methods: [Method]) {
			self.name = name
			self.constructor = constructor
			self.methods = methods
		}
		
		// See protocol.
		public var name: TypeName
		
		/// The constructor for objects of this type.
		public var constructor: Constructor
		
		/// The methods for objects of this type.
		public var methods: [Method]
		
		/// Determines the record type of the state of objects of this type.
		func stateRecordType(in context: Context) throws -> RecordType {
			guard case .cap(.record(let recordType)) = try constructor.result.type(in: context) else {
				throw TypingError.nonrecordConstructor(name, constructor.result)
			}
			return recordType
		}
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.ObjectType {
			try .init(name, constructor: constructor.lowered(in: &context), methods: methods.lowered(in: &context))
		}
		
	}
	
}
