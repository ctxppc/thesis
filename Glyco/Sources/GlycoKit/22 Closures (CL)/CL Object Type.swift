// Glyco © 2021–2022 Constantino Tsarouhas

extension CL {
	
	/// A value denoting the type of an object.
	public struct ObjectType : Named, Element, SimplyLowerable {
		
		/// Creates an object type with given name, initial state, initialiser, and methods.
		public init(_ name: TypeName, initialState: [RecordEntry], initialiser: Initialiser, methods: [Method]) {
			self.name = name
			self.initialState = initialState
			self.initialiser = initialiser
			self.methods = methods
		}
		
		// See protocol.
		public var name: TypeName
		
		/// The initial state of objects of this type, before the initialiser is executed.
		public var initialState: [RecordEntry]
		
		/// The initialiser for objects of this type.
		public var initialiser: Initialiser
		
		/// The methods for objects of this type.
		public var methods: [Method]
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.ObjectType {
			try .init(
				name,
				initialState:	initialState.lowered(in: &context),
				initialiser:	initialiser.lowered(in: &context),
				methods:		methods.lowered(in: &context)
			)
		}
		
	}
	
}
