// Glyco © 2021–2022 Constantino Tsarouhas

extension CL {
	
	/// A value denoting the type of an object.
	public struct ObjectType : Named, Element, SimplyLowerable {
		
		/// Creates an object type with given name, initialiser, and methods.
		public init(_ name: TypeName, initialiser: Initialiser, methods: [Method]) {
			self.name = name
			self.initialiser = initialiser
			self.methods = methods
		}
		
		// See protocol.
		public var name: TypeName
		
		/// The initialiser for objects of this type.
		public var initialiser: Initialiser
		
		/// The methods for objects of this type.
		public var methods: [Method]
		
		/// Determines the record type of the state of objects of this type.
		func stateRecordType(in context: Context) throws -> RecordType {
			guard case .cap(.record(let recordType)) = try initialiser.result.type(in: context) else {
				throw TypingError.nonrecordInitialiser(name, initialiser.result)
			}
			return recordType
		}
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.ObjectType {
			try .init(name, initialiser: initialiser.lowered(in: &context), methods: methods.lowered(in: &context))
		}
		
	}
	
}
