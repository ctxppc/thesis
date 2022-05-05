// Glyco © 2021–2022 Constantino Tsarouhas

extension OB {
	
	/// A value denoting the type of an object.
	public struct ObjectType : Named, Element {
		
		/// Creates an object type with given name, initialiser, methods, and state record type.
		public init(_ name: TypeName, state: RecordType, initialiser: Initialiser, methods: [Method]) {
			self.name = name
			self.initialiser = initialiser
			self.methods = methods
			self.state = state
		}
		
		// See protocol.
		public var name: TypeName
		
		/// The record type for objects of this type.
		public var state: RecordType
		
		/// The initialiser for objects of this type.
		public var initialiser: Initialiser
		
		/// The methods for objects of this type.
		public var methods: [Method]
		
		/// The name of the type object representing `self`, as defined by a `letType` value.
		var typeObjectName: Lower.Symbol {
			"ob.\(name).type"
		}
		
		/// The name of the metatype of `self`, i.e., the name of the type of the object bound to `typeObjectName`.
		var typeObjectTypeName: TypeName {
			"ob.\(name).Type"
		}
		
		/// The name of the `createObject` method that can be invoked on the object bound to `typeObjectName`.
		///
		/// The `createObject` method's parameters correspond exactly with `initialiser`'s parameters.
		static let typeObjectCreateObjectMethod: Method.Name = "createObject"
		
		/// The state record type of type objects.
		static let typeObjectState = RecordType([
			.init(Self.typeObjectSealFieldName, .cap(.seal)),
		])
		
		/// The name of the type object field containing the seal capability used for sealing objects of that type.
		static let typeObjectSealFieldName: Field.Name = "seal"
		
	}
	
}
