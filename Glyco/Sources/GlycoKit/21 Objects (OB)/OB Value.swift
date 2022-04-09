// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

extension OB {
	public enum Value : Codable, Equatable, SimplyLowerable {
		
		/// A value that evaluates to an unsealed capability to the current object.
		///
		/// `self` is not valid outside methods.
		case `self`
		
		/// A value that evaluates to given number.
		case constant(Int)
		
		/// A value that evaluates to the named value associated with given name in the environment.
		case named(Symbol)
		
		/// A value that evaluates to a unique capability to an uninitialised record of given type.
		case record(RecordType)
		
		/// A value that evaluates to the field with given name in the record `of`.
		indirect case field(Field.Name, of: Value)
		
		/// A value that evaluates to a unique capability to an uninitialised vector of `count` elements of given data type.
		case vector(ValueType, count: Int)
		
		/// A value that evaluates to the `at`th element of the list `of`.
		indirect case element(of: Value, at: Value)
		
		/// A value that evaluates to a unique capability to an object constructed with given arguments.
		case object(TypeName, [Value])
		
		/// A value representing a globally defined function with given name.
		case function(Label)
		
		/// A value that evaluates to *x* *op* *y* where *x* and *y* are given sources and *op* is given operator.
		indirect case binary(Value, BinaryOperator, Value)
		
		/// A value that evaluates to given function evaluated with given arguments.
		indirect case evaluate(Value, [Value])
		
		/// A value that messages the object with given object capability, method name, and arguments.
		indirect case message(Value, Method.Name, [Value])
		
		/// A value that evaluates to the value of `then` if the predicate holds, or to the value of `else` otherwise.
		indirect case `if`(Predicate, then: Value, else: Value)
		
		/// A value that evaluates to given value after associating zero or more values with a name.
		indirect case `let`([Definition], in: Value)
		
		/// A value that evaluates to given value after associating zero or more types with a name.
		indirect case letType([TypeDefinition], in: Value)
		
		/// A value that evaluates to given value after performing given effects.
		indirect case `do`([Effect], then: Value)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Value {
			switch self {
				
				case .self:
				return .named(Method.selfName)
				
				case .constant(let value):
				return .constant(value)
					
				case .named(let symbol):
				return .named(symbol)
				
				case .record(let type):
				return .record(try type.lowered(in: &context))
				
				case .field(let fieldName, of: let record):
				return .field(fieldName, of: try record.lowered(in: &context))
				
				case .vector(let elementType, count: let count):
				return .vector(try elementType.lowered(in: &context), count: count)
				
				case .element(of: let vector, at: let index):
				return try .element(of: vector.lowered(in: &context), at: index.lowered(in: &context))
				
				case .object(let typeName, let arguments):
				guard let definition = context.type(named: typeName) else { throw TypingError.unknownObjectType(typeName) }
				guard case .object(_, let objectType) = definition else { throw TypingError.notAnObjectTypeDefinition(typeName, actual: definition) }
				return .evaluate(.named(objectType.initialiserSymbol(typeName: typeName)), try arguments.lowered(in: &context))
				
				case .function(let name):
				return .function(name)
				
				case .binary(let lhs, let op, let rhs):
				return try .binary(lhs.lowered(in: &context), op, rhs.lowered(in: &context))
				
				case .evaluate(let function, let arguments):
				return try .evaluate(function.lowered(in: &context), arguments.lowered(in: &context))
				
				case .message(let receiver, let methodName, let arguments):
				let receiverType = try receiver.type(in: context)
				guard case .cap(.object(let typeName)) = receiverType else { throw TypingError.nonobjectReceiver(receiver, actualType: receiverType) }
				guard let typeDefinition = context.type(named: typeName) else { throw TypingError.unknownObjectType(typeName) }
				guard case .object(_, let objectType) = typeDefinition else { throw TypingError.notAnObjectTypeDefinition(typeName, actual: typeDefinition) }
				guard let method = objectType.methods[methodName] else { throw TypingError.undefinedMethod(receiver: receiver, objectType: objectType, methodName: methodName) }
				return .evaluate(.named(method.symbol(typeName: typeName)), try arguments.lowered(in: &context))
				
				case .if(let predicate, then: let affirmative, else: let negative):
				return try .if(predicate.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .let(let definitions, in: let body):
				return try .let(definitions.lowered(in: &context), in: body.lowered(in: &context))
				
				case .letType(let definitions, in: let body):
				context.types.append(contentsOf: definitions)
				defer { context.types.removeLast(definitions.count) }
				return try .letType(definitions.lowered(in: &context), in: body.lowered(in: &context))
				
				case .do(let effects, then: let value):
				return try .do(effects.lowered(in: &context), then: value.lowered(in: &context))
				
			}
		}
		
		/// Determines the type of `self`.
		private func type(in context: Context) throws -> ValueType {
			switch self {
				
				case .self:
				TODO.unimplemented
				
				case .constant(let value):
				return .s32
					
				case .named(let symbol):
				TODO.unimplemented
				
				case .record(let type):
				return .cap(.record(type))
				
				case .field(let fieldName, of: let record):
				TODO.unimplemented
				
				case .vector(let elementType, count: _):
				return .cap(.vector(of: elementType))
				
				case .element(of: let vector, at: let index):
				TODO.unimplemented
				
				case .object(let typeName, let arguments):
				TODO.unimplemented
				
				case .function(let name):
				TODO.unimplemented
				
				case .binary:
				return .s32
				
				case .evaluate(let function, let arguments):
				TODO.unimplemented
				
				case .message(let receiver, let methodName, let arguments):
				TODO.unimplemented
				
				case .if(let predicate, then: let affirmative, else: let negative):
				return try affirmative.type(in: context)
				
				case .let(let definitions, in: let body):
				return try body.type(in: context)
				
				case .letType(let definitions, in: let body):
				return try body.type(in: context)
				
				case .do(let effects, then: let value):
				return try value.type(in: context)
				
			}
		}
		
		enum TypingError : LocalizedError {
			
			/// An error indicating that the receiver of a message is not an object.
			case nonobjectReceiver(Value, actualType: ValueType)
			
			/// An error indicating that no object type is known by given name.
			case unknownObjectType(TypeName)
			
			/// An error indicating the type defined with given name is not an object type.
			case notAnObjectTypeDefinition(TypeName, actual: TypeDefinition)
			
			/// An error indicating that given receiver of given object type does not defined a method with given name.
			case undefinedMethod(receiver: Value, objectType: ObjectType, methodName: Method.Name)
			
			// See protocol.
			var errorDescription: String? {
				switch self {
					
					case .nonobjectReceiver(let receiver, actualType: let actualType):
					return "\(receiver) is not an object but a(n) \(actualType)"
					
					case .unknownObjectType(let typeName):
					return "“\(typeName)” is not a known object type"
					
					case .notAnObjectTypeDefinition(let typeName, actual: let actual):
					return "“\(typeName)” is defined as \(actual) and thus not an object type"
					
					case .undefinedMethod(receiver: let receiver, objectType: let objectType, methodName: let methodName):
					return "\(receiver) (of type \(objectType)) does not define a method “\(methodName)”"
					
				}
			}
			
		}
		
	}
}
