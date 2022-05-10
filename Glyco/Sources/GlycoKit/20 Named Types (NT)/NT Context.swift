// Glyco © 2021–2022 Constantino Tsarouhas

extension NT {
	
	/// A value used while lowering a program.
	struct LoweringContext : NTTypeContext {
		
		// See protocol.
		func type(named name: TypeName) -> TypeDefinition? {
			types.reversed()[name]
		}
		
		/// The type definitions in the current scope, from oldest to newest.
		var types = [TypeDefinition]()
		
	}
	
	/// A value used while typing.
	struct TypingContext : NTTypeContext {
		
		/// The type definitions in the current scope, from oldest to newest.
		var types = [TypeDefinition]()
		
		// See protocol.
		func type(named name: TypeName) -> TypeDefinition? {
			types.reversed()[name]
		}
		
		/// A mapping from symbols to assigned types.
		var assignedTypesBySymbol = [Symbol : AssignedValueType]()
		
	}
	
	/// A type assigned to a value.
	struct AssignedValueType {
		
		/// Determines the value type assigned to a value in some context.
		init(from actual: ValueType, in context: TypingContext) {
			self.actual = actual
			self.context = context
		}
		
		/// The value's actual type, without any type name resolution.
		let actual: ValueType
		
		/// The typing context of `actual`.
		let context: TypingContext
		
		/// Returns the value's normalised type.
		func normalised(recursively: Bool = true) throws -> ValueType {
			try actual.normalised(in: context, recursively: recursively)
		}
		
		/// Returns the value's structural type.
		func structural(recursively: Bool = true) throws -> ValueType {
			try actual.structural(in: context, recursively: recursively)
		}
		
	}
	
}

protocol NTTypeContext {
	
	/// Returns the newest definition of a type with given name.
	func type(named name: NT.TypeName) -> NT.TypeDefinition?
	
}
