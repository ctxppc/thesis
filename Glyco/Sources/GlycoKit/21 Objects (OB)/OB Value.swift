// Glyco © 2021–2022 Constantino Tsarouhas

import DepthKit
import Foundation
import Sisp

extension OB {
	public enum Value : PartiallyStringCodable, PartiallyIntCodable, SimplyLowerable, Element {
		
		/// A value that evaluates to an unsealed capability to the current object.
		///
		/// `self` is not valid outside methods.
		case `self`
		
		/// A value that evaluates to given number.
		case constant(Int)
		
		/// A value that evaluates to the named value associated with given name in the environment.
		case named(Symbol)
		
		/// A value that evaluates to a unique capability to a record with given entries.
		indirect case record([RecordEntry])
		
		/// A value that evaluates to the field with given name in the record `of`.
		///
		/// The record may be of a nominal type.
		indirect case field(Field.Name, of: Value)
		
		/// A value that evaluates to a unique capability to a vector of `count` copies of given value.
		indirect case vector(Value, count: Int)
		
		/// A value that evaluates to the `at`th element of the list `of`.
		///
		/// The vector may be of a nominal type.
		indirect case element(of: Value, at: Value)
		
		/// A value that evaluates to an anonymous function with given parameters, result type, and result.
		///
		/// Enclosing definitions are not available within the lambda body.
		indirect case λ(takes: [Parameter], returns: ValueType, in: Result)
		
		/// A value that evaluates to a unique capability to an object constructed with given arguments.
		case object(TypeName, [Value])
		
		/// A value that evaluates to *x* *op* *y* where *x* and *y* are given sources and *op* is given operator.
		indirect case binary(Value, BinaryOperator, Value)
		
		/// A value that evaluates to given function or message evaluated with given arguments.
		indirect case evaluate(Value, [Value])
		
		/// A value that evaluates to a message, i.e., a method bound to an object.
		indirect case message(Value, Method.Name)
		
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
				
				case .record(let entries):
				return .record(try entries.lowered(in: &context))
				
				case .field(let fieldName, of: let record):
				return .field(fieldName, of: try record.lowered(in: &context))
				
				case .vector(let repeatedElement, count: let count):
				return .vector(try repeatedElement.lowered(in: &context), count: count)
				
				case .λ(takes: let parameters, returns: let resultType, in: let body):
				var deeperContext = Context(
					types:				context.types,
					valueTypesBySymbol:	.init(uniqueKeysWithValues: parameters.lazy.map { ($0.name, [$0.type]) })
				)
				return try .λ(takes: parameters.lowered(in: &context), returns: resultType.lowered(in: &context), in: body.lowered(in: &deeperContext))
				
				case .element(of: let vector, at: let index):
				return try .element(of: vector.lowered(in: &context), at: index.lowered(in: &context))
				
				case .object(let typeName, let arguments):
				guard let definition = context.type(named: typeName) else { throw TypingError.unknownObjectType(typeName) }
				guard case .object(let objectType) = definition else { throw TypingError.notAnObjectTypeDefinition(typeName, actual: definition) }
				return .evaluate(
					.named(Method.symbol(typeName: objectType.typeObjectTypeName, methodName: ObjectType.typeObjectCreateObjectMethod)),
					try [.named(objectType.typeObjectName)] + arguments.lowered(in: &context)
				)
				
				case .binary(let lhs, let op, let rhs):
				return try .binary(lhs.lowered(in: &context), op, rhs.lowered(in: &context))
				
				case .evaluate(.message(let receiver, let methodName), let arguments):	// Optimisation: avoid allocating a pair by inlining the message.
				let receiverType = try receiver.type(in: context)
				guard case .cap(.object(let typeName)) = receiverType else { throw TypingError.messagingNonobject(receiver, actualType: receiverType) }
				guard let typeDefinition = context.type(named: typeName) else { throw TypingError.unknownObjectType(typeName) }
				guard case .object(let objectType) = typeDefinition else { throw TypingError.notAnObjectTypeDefinition(typeName, actual: typeDefinition) }
				guard let method = objectType.methods[methodName] else { throw TypingError.undefinedMethod(receiver: receiver, objectType: objectType, methodName: methodName) }
				return .evaluate(.named(method.symbol(typeName: typeName)), try [receiver.lowered(in: &context)] + arguments.lowered(in: &context))
				
				case .evaluate(let target, let arguments):
				if case .cap(.message) = try target.type(in: context) {
					return try .evaluate(
						.field(ObjectType.boundMethodFieldForMethod, of: target.lowered(in: &context)),
						[.field(ObjectType.boundMethodFieldForReceiver, of: target.lowered(in: &context))] + arguments.lowered(in: &context)
					)
				} else {
					return try .evaluate(target.lowered(in: &context), arguments.lowered(in: &context))
				}
				
				case .message(let receiver, let methodName):
				let receiverType = try receiver.type(in: context)
				guard case .cap(.object(let typeName)) = receiverType else { throw TypingError.messagingNonobject(receiver, actualType: receiverType) }
				guard let typeDefinition = context.type(named: typeName) else { throw TypingError.unknownObjectType(typeName) }
				guard case .object(let objectType) = typeDefinition else { throw TypingError.notAnObjectTypeDefinition(typeName, actual: typeDefinition) }
				guard let method = objectType.methods[methodName] else { throw TypingError.undefinedMethod(receiver: receiver, objectType: objectType, methodName: methodName) }
				return .record([
					.init(ObjectType.boundMethodFieldForReceiver, try receiver.lowered(in: &context)),
					.init(ObjectType.boundMethodFieldForMethod, .named(method.symbol(typeName: typeName))),
				])
				
				case .if(let predicate, then: let affirmative, else: let negative):
				return try .if(predicate.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .let(let definitions, in: let body):
				for definition in definitions {
					context.declare(definition.name, try definition.value.type(in: context))
				}
				defer {
					for definition in definitions.reversed() {
						context.undeclare(definition.name)
					}
				}
				return try .let(definitions.lowered(in: &context), in: body.lowered(in: &context))
				
				case .letType(let typeDefinitions, in: let body):
				context.types.append(contentsOf: typeDefinitions)
				defer { context.types.removeLast(typeDefinitions.count) }
				return try .letType(
					typeDefinitions.lowered(in: &context),
					in: .let(.init {
						for case .object(let objectType) in typeDefinitions {
							
							let previousObjectTypeName = context.objectTypeName
							context.objectTypeName = objectType.name
							
							// A fresh seal for sealing the type object and its createObject method.
							let typeSeal: Lower.Symbol = "ob.tseal"
							typeSeal ~ .seal
							
							// A fresh seal for sealing the the type's objects and methods.
							let objectSeal: Lower.Symbol = "ob.oseal"
							objectSeal ~ .seal
							
							// The type object.
							let unsealedTypeObject: Lower.Symbol = "ob.typeobj"
							objectType.typeObjectName ~ .let(
								[unsealedTypeObject ~ .record([.init(ObjectType.typeObjectSealFieldName, .named(objectSeal))])],
								in: .sealed(.named(unsealedTypeObject), with: .named(typeSeal))
							)
							
							// The type object's createObject method.
							Method.symbol(
								typeName: objectType.typeObjectTypeName,
								methodName: ObjectType.typeObjectCreateObjectMethod
							) ~ .sealed(
								try objectType.initialiser.lowered(in: &context, type: objectType),
								with: .named(typeSeal)
							)
							
							// The type's methods.
							for method in objectType.methods {
								method.symbol(typeName: objectType.name) ~ .sealed(
									try method.lowered(in: &context, type: objectType),
									with: .named(objectSeal)
								)
							}
							
							context.objectTypeName = previousObjectTypeName
							
						}
					}, in: body.lowered(in: &context))
				)
				
				case .do(let effects, then: let value):
				return try .do(effects.lowered(in: &context), then: value.lowered(in: &context))
				
			}
		}
		
		/// Determines the type of `self`.
		func type(in context: Context) throws -> ValueType {
			switch self {
				
				case .self:
				guard let typeName = context.objectTypeName else { throw TypingError.selfOutsideMethod }
				return .cap(.object(typeName))
				
				case .constant:
				return .s32
				
				case .named(let symbol):
				guard let type = context.valueType(of: symbol) else { throw TypingError.undefinedSymbol(symbol) }
				return type
				
				case .record(let entries):
				return .cap(.record(.init(try entries.map { try .init($0.name, $0.value.type(in: context)) })))
				
				case .field(let fieldName, of: let record):
				let recordType: RecordType = try {
					switch try record.type(in: context) {
						
						case .cap(.record(let recordType)):
						return recordType
						
						case .cap(.object(let typeName)):
						guard case .object(let objectType) = context.types[typeName] else { throw TypingError.unknownObjectType(typeName) }
						return try objectType.stateRecordType(in: context)
						
						default:
						throw TypingError.subscriptingNonrecord(record, fieldName: fieldName)
						
					}
				}()
				guard let field = recordType.fields[fieldName] else { throw TypingError.undefinedField(fieldName, record, recordType) }
				return field.valueType
				
				case .vector(let repeatedElement, count: _):
				return .cap(.vector(of: try repeatedElement.type(in: context)))
				
				case .element(of: let vector, at: let index):
				guard case .cap(.vector(of: let elementType)) = try vector.type(in: context) else { throw TypingError.indexingNonvector(vector, index: index) }
				return elementType
				
				case .λ(takes: let parameters, returns: let resultType, in: _):
				return .cap(.function(takes: parameters, returns: resultType))
				
				case .object(let typeName, _):
				return .cap(.object(typeName))
				
				case .binary:
				return .s32
				
				case .evaluate(let target, let arguments):
				switch try target.type(in: context) {
					
					case .cap(.function(takes: _, returns: let resultType)),
						.cap(.message(takes: _, returns: let resultType)):
					return resultType
					
					default:
					throw TypingError.evaluatingNonfunction(target, arguments)
					
				}
				
				case .message(let receiver, let methodName):
				let receiverType = try receiver.type(in: context)
				guard case .cap(.object(let typeName)) = receiverType else { throw TypingError.messagingNonobject(receiver, actualType: receiverType) }
				guard let typeDefinition = context.type(named: typeName) else { throw TypingError.unknownObjectType(typeName) }
				guard case .object(let objectType) = typeDefinition else { throw TypingError.notAnObjectTypeDefinition(typeName, actual: typeDefinition) }
				guard let method = objectType.methods[methodName] else { throw TypingError.undefinedMethod(receiver: receiver, objectType: objectType, methodName: methodName) }
				return .cap(.message(takes: method.parameters, returns: method.resultType))
				
				case .if(_, then: let affirmative, else: _):
				return try affirmative.type(in: context)
				
				case .let(let definitions, in: let body):
				var context = context
				for definition in definitions {
					context.declare(definition.name, try definition.value.type(in: context))
				}
				return try body.type(in: context)
				
				case .letType(let definitions, in: let body):
				var context = context
				context.types.append(contentsOf: definitions)
				return try body.type(in: context)
				
				case .do(_, then: let value):
				return try value.type(in: context)
				
			}
		}
		
	}
	
	enum TypingError : LocalizedError {
		
		/// An error indicating that `self` is used outside of a method.
		case selfOutsideMethod
		
		/// An error indicating that given symbol is not defined.
		case undefinedSymbol(Symbol)
		
		/// An error indicating that a nonrecord is being subscripted.
		case subscriptingNonrecord(Value, fieldName: Field.Name)
		
		/// An error indicating that given field is not defined on given record.
		case undefinedField(Field.Name, Value, RecordType)
		
		/// An error indicating that a nonvector is being indexed.
		case indexingNonvector(Value, index: Value)
		
		/// An error indicating that a nonfunction is being evaluated.
		case evaluatingNonfunction(Value, [Value])
		
		/// An error indicating that the receiver of a message is not an object.
		case messagingNonobject(Value, actualType: ValueType)
		
		/// An error indicating that no object type is known by given name.
		case unknownObjectType(TypeName)
		
		/// An error indicating the type defined with given name is not an object type.
		case notAnObjectTypeDefinition(TypeName, actual: TypeDefinition)
		
		/// An error indicating that given receiver of given object type does not defined a method with given name.
		case undefinedMethod(receiver: Value, objectType: ObjectType, methodName: Method.Name)
		
		/// An error indicating the initialiser of the object type with given name doesn't produce a record capability value.
		case nonrecordInitialiser(TypeName, Value)
		
		// See protocol.
		var errorDescription: String? {
			switch self {
				
				case .selfOutsideMethod:
				return "Use of self outside a method"
				
				case .undefinedSymbol(let symbol):
				return "“\(symbol)” is not defined"
				
				case .subscriptingNonrecord(let record, fieldName: let fieldName):
				return "\(record) is not a record and thus cannot be subscripted with “\(fieldName)”"
				
				case .undefinedField(let fieldName, let record, let recordType):
				return "\(record) (\(recordType)) does not have a field “\(fieldName)”"
				
				case .indexingNonvector(let vector, index: let index):
				return "\(vector) is not a vector and thus cannot be indexed with \(index)"
				
				case .evaluatingNonfunction(let function, let arguments):
				return "\(function) is not a function and thus cannot be evaluated with \(arguments)"
				
				case .messagingNonobject(let receiver, actualType: let actualType):
				return "\(receiver) is not an object but a(n) \(actualType)"
				
				case .unknownObjectType(let typeName):
				return "“\(typeName)” is not a known object type"
				
				case .notAnObjectTypeDefinition(let typeName, actual: let actual):
				return "“\(typeName)” is defined as \(actual) and thus not an object type"
				
				case .undefinedMethod(receiver: let receiver, objectType: let objectType, methodName: let methodName):
				return "\(receiver) (of type \(objectType)) does not define a method “\(methodName)”"
				
				case .nonrecordInitialiser(let typeName, let result):
				return "\(typeName)‘s initialiser produces \(result), which isn‘t a record capability"
				
			}
		}
		
	}
	
}
