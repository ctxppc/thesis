// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation
import Sisp

extension NT {
	
	public enum Value : PartiallyStringCodable, PartiallyIntCodable, SimplyLowerable, Element {
		
		/// A value that evaluates to given number.
		case constant(Int)
		
		/// A value that evaluates to the named value associated with given name in the environment.
		case named(Symbol)
		
		/// A value that evaluates to a unique capability to an uninitialised record of given type.
		case record(RecordType)
		
		/// A value that evaluates to the field with given name in the record `of`.
		///
		/// The record may be of a nominal type.
		indirect case field(Field.Name, of: Value)
		
		/// A value that evaluates to a unique capability to an uninitialised vector of `count` elements of given data type.
		case vector(ValueType, count: Int)
		
		/// A value that evaluates to the `at`th element of the list `of`.
		///
		/// The vector may be of a nominal type.
		indirect case element(of: Value, at: Value)
		
		/// A value that evaluates to an anonymous function with given parameters, result type, and result.
		///
		/// If the result type is a nominal type and the result is of a structural type, it is implicitly converted.
		indirect case λ(takes: [Parameter], returns: ValueType, in: Result)
		
		/// A value representing a globally defined function with given name.
		case function(Label)
		
		/// A value that evaluates to a unique capability that can be used for sealing.
		case seal
		
		/// A value that evaluates to the first capability after sealing it with the (second) seal capability.
		///
		/// The seal may be of a nominal type.
		indirect case sealed(Value, with: Value)
		
		/// A value that evaluates to *x* *op* *y* where *x* and *y* are given sources and *op* is given operator.
		///
		/// The operands may be of a nominal (numeric) type. If both operands are of a nominal type, the types must be equal.
		indirect case binary(Value, BinaryOperator, Value)
		
		/// A value that evaluates to given function evaluated with given arguments.
		///
		/// The function may be of a nominal type. Each argument of structural type is implicitly converted if the corresponding parameter is of nominal type.
		indirect case evaluate(Value, [Value])
		
		/// A value that evaluates to given value but is typed as given type, ignoring nominal typing rules.
		indirect case cast(Value, as: ValueType)
		
		/// A value that evaluates to the value of `then` if the predicate holds, or to the value of `else` otherwise.
		indirect case `if`(Predicate, then: Value, else: Value)
		
		/// A value that evaluates to given value after associating zero or more values with a name.
		indirect case `let`([Definition], in: Value)
		
		/// A value that evaluates to given value after associating zero or more types with a name.
		indirect case letType([TypeDefinition], in: Value)
		
		/// A value that evaluates to given value after performing given effects.
		indirect case `do`([Effect], then: Value)
		
		// See protocol.
		func lowered(in context: inout LoweringContext) throws -> Lower.Value {
			switch self {
				
				case .constant(let value):
				return .constant(value)
					
				case .named(let symbol):
				return .named(symbol)
				
				case .record(let type):
				return .record(try type.lowered(in: &context))
				
				case .field(let fieldName, of: let record):
				return .field(fieldName, of: try record.lowered(in: &context))
				
				case .vector(let valueType, count: let count):
				return .vector(try valueType.lowered(in: &context), count: count)
				
				case .element(of: let vector, at: let index):
				return try .element(of: vector.lowered(in: &context), at: index.lowered(in: &context))
				
				case .λ(takes: let parameters, returns: let resultType, in: let result):
				return try .λ(
					takes:		parameters.lowered(in: &context),
					returns:	resultType.lowered(in: &context),
					in:			result.lowered(in: &context)
				)
				
				case .function(let name):
				return .function(name)
				
				case .seal:
				return .seal
				
				case .sealed(let cap, with: let seal):
				return try .sealed(cap.lowered(in: &context), with: seal.lowered(in: &context))
				
				case .binary(let lhs, let op, let rhs):
				return try .binary(lhs.lowered(in: &context), op, rhs.lowered(in: &context))
				
				case .evaluate(let function, let arguments):
				return try .evaluate(function.lowered(in: &context), arguments.lowered(in: &context))
				
				case .cast(let value, as: _):
				return try value.lowered(in: &context)
				
				case .if(let predicate, then: let affirmative, else: let negative):
				return try .if(
					predicate.lowered(in: &context),
					then: affirmative.lowered(in: &context),
					else: negative.lowered(in: &context)
				)
				
				case .let(let definitions, in: let body):
				return try .let(definitions.lowered(in: &context), in: body.lowered(in: &context))
				
				case .letType(let definitions, in: let body):
				context.types.append(contentsOf: definitions)
				defer { context.types.removeLast(definitions.count) }
				return try body.lowered(in: &context)
				
				case .do(let effects, then: let value):
				return try .do(effects.lowered(in: &context), then: value.lowered(in: &context))
				
			}
		}
		
		/// Determines the type of `self`.
		func assignedType(in context: TypingContext) throws -> AssignedValueType {
			switch self {
				
				case .constant:
				return .init(from: .s32, in: context)
					
				case .named(let symbol):
				guard let type = context.assignedTypesBySymbol[symbol] else { throw TypingError.undefinedSymbol(symbol) }
				return type
				
				case .record(let type):
				return .init(from: .cap(.record(type, sealed: false)), in: context)
				
				case .field(let fieldName, of: let record):
				guard case .cap(.record(let recordType, sealed: false)) = try record.assignedType(in: context).structural(recursively: false) else {
					throw TypingError.notAnUnsealedRecord(record)
				}
				guard let field = recordType.fields[fieldName] else {
					throw TypingError.unknownFieldName(fieldName, recordType, record)
				}
				return .init(from: field.valueType, in: context)
				
				case .vector(let elementType, count: _):
				return .init(from: .cap(.vector(of: elementType, sealed: false)), in: context)
				
				case .element(of: let vector, at: let index):
				guard case .cap(.vector(of: let elementType, sealed: false)) = try vector.assignedType(in: context).structural(recursively: false) else {
					throw TypingError.notAnUnsealedVector(vector)
				}
				guard try index.assignedType(in: context).normalised() == .s32 else { throw TypingError.nonnumericIndex(index, vector: vector) }
				return .init(from: elementType, in: context)
				
				case .λ(takes: let parameters, returns: let resultType, in: let result):
				do {
					
					var bodyContext = context
					bodyContext.assignedTypesBySymbol = .init(uniqueKeysWithValues: try parameters.map { parameter in
						if parameter.sealed {
							guard case .cap(let capType) = parameter.type else { throw TypingError.noncapabilitySealedParameter(parameter) }
							return (parameter.name, .init(from: .cap(capType.sealed(false)), in: context))
						} else {
							return (parameter.name, .init(from: parameter.type, in: context))
						}
					})
					
					let normalisedDeclaredResultType = try resultType.normalised(in: context)
					let normalisedActualResultType = try result.assignedType(in: bodyContext).normalised()
					
					let typesMatchDirectly = normalisedActualResultType == normalisedDeclaredResultType
					let typesMatchAfterConversion = { try normalisedActualResultType == normalisedDeclaredResultType.structural(in: context) }
					guard try typesMatchDirectly || typesMatchAfterConversion() else {
						throw TypingError.resultTypeMismatch(result, expected: normalisedDeclaredResultType, actual: normalisedActualResultType)
					}
					
					return .init(from: .cap(.function(takes: parameters, returns: resultType)), in: context)
					
				}
				
				case .function(let name):
				guard let function = context.functions[name] else { throw TypingError.undefinedFunction(name) }
				return .init(from: .cap(.function(takes: function.parameters, returns: function.resultType)), in: context)
				
				case .seal:
				return .init(from: .cap(.seal(sealed: false)), in: context)
				
				case .sealed(let cap, with: let seal):
				guard case .cap(let capType) = try cap.assignedType(in: context).normalised() else { throw TypingError.noncapabilityValue(cap) }
				guard case .cap(.seal(sealed: false)) = try seal.assignedType(in: context).structural() else { throw TypingError.notAnUnsealedSealCapability(cap) }
				switch capType {
					
					case .vector(of: let elementType, sealed: false):
					return .init(from: .cap(.vector(of: elementType, sealed: true)), in: context)
					
					case .record(let recordType, sealed: false):
					return .init(from: .cap(.record(recordType, sealed: true)), in: context)
					
					case .function:
					return .init(from: .cap(capType), in: context)
					
					case .seal(sealed: false):
					return .init(from: .cap(.seal(sealed: true)), in: context)
					
					case .vector(of: _, sealed: true),
						.record(_, sealed: true),
						.seal(sealed: true):
					throw TypingError.sealedCapability(cap)
					
				}
				
				case .binary(let lhs, _, let rhs):
				let lhsType = try lhs.assignedType(in: context)
				let rhsType = try rhs.assignedType(in: context)
				guard try lhsType.structural() == .s32 else { throw TypingError.nonnumericOperand(lhs) }
				guard try rhsType.structural() == .s32 else { throw TypingError.nonnumericOperand(rhs) }
				switch try (lhsType.normalised(), rhsType.normalised()) {
					
					case (.named(let name), .named(let otherName)) where name == otherName:
					return .init(from: .named(name), in: context)
					
					case (.named(let name), .s32), (.s32, .named(let name)):
					return .init(from: .named(name), in: context)
					
					case (.s32, .s32):
					return .init(from: .s32, in: context)
					
					case (let lhsType, let rhsType):
					throw TypingError.operandTypeMismatch(lhs, rhs, lhsType, rhsType)
					
				}
				
				case .evaluate(let function, let arguments):
				let functionType = try function.assignedType(in: context).structural(recursively: false)
				guard case .cap(.function(takes: let parameters, returns: let resultType)) = functionType else { throw TypingError.nonfunctionValue(function) }
				for (parameter, argument) in zip(parameters, arguments) {
					
					let argumentType = try argument.assignedType(in: context)
					
					// Basic typing rule. (If not checked here, it will fail in a later nanopass.)
					if try argumentType.structural() != parameter.type.structural(in: context) {
						throw TypingError.argumentTypeMismatch(argument, argumentType.actual, parameter)
					}
					
					// If the argument is of nominal type, parameter must be of matching nominal type.
					if case .named(let name) = try argumentType.normalised() {
						guard case .named(name) = try parameter.type.normalised(in: context) else {
							throw TypingError.argumentTypeMismatch(argument, argumentType.actual, parameter)
						}
					}
					
				}
				return .init(from: resultType, in: context)
				
				case .cast(let value, as: let type):
				let sourceType = try value.assignedType(in: context)
				let targetType = AssignedValueType(from: type, in: context)
				guard try sourceType.structural() == targetType.structural() else {
					throw TypingError.incompatibleStructuralTypes(castedValue: value, sourceType: sourceType.actual, targetType: targetType.actual)
				}
				return targetType
				
				case .if(_, then: let affirmative, else: let negative):
				// TODO: Type-check predicate?
				let affirmativeType = try affirmative.assignedType(in: context).normalised()
				let negativeType = try negative.assignedType(in: context).normalised()
				guard affirmativeType == negativeType else { throw TypingError.branchTypeMismatch(affirmative: affirmativeType, negative: negativeType) }
				return .init(from: affirmativeType, in: context)
				
				case .let(let definitions, in: let body):
				var context = context
				for definition in definitions {
					context.assignedTypesBySymbol[definition.name] = try definition.value.assignedType(in: context)
				}
				return try body.assignedType(in: context)
				
				case .letType(let definitions, in: let body):
				var context = context
				context.types.append(contentsOf: definitions)
				return try body.assignedType(in: context)
				
				case .do(_, then: let value):
				// TODO: Type-check effects?
				return try value.assignedType(in: context)
				
			}
		}
		
	}
	
	enum TypingError : LocalizedError {
		
		/// An error indicating that given symbol is not defined.
		case undefinedSymbol(Symbol)
		
		/// An error indicating that given value is not an unsealed record capability.
		case notAnUnsealedRecord(Value)
		
		/// An error indicating that given field name is not part of given record type.
		case unknownFieldName(Field.Name, RecordType, Value)
		
		/// An error indicating that given value is not an unsealed vector capability.
		case notAnUnsealedVector(Value)
		
		/// An error indicating that given value is not a number that can be used as an index for given vector.
		case nonnumericIndex(Value, vector: Value)
		
		/// An error indicating that given result does not conform to the declared result type.
		case resultTypeMismatch(Result, expected: ValueType, actual: ValueType)
		
		/// An error indicating that a function with given name is not defined.
		case undefinedFunction(Label)
		
		/// An error indicating that given value is not an unsealed capability.
		case noncapabilityValue(Value)
		
		/// An error indicating that given value is not an unsealed seal capability.
		case notAnUnsealedSealCapability(Value)
		
		/// An error indicating that given value is a sealed capability.
		case sealedCapability(Value)
		
		/// An error indicating that given value is not a number that can be used in a binary operation.
		case nonnumericOperand(Value)
		
		/// An error indicating the operands do not have matching types.
		case operandTypeMismatch(Value, Value, ValueType, ValueType)
		
		/// An error indicating that given value is not a function that can be evaluated.
		case nonfunctionValue(Value)
		
		/// An error indicating that given argument has the wrong type for given parameter.
		case argumentTypeMismatch(Value, ValueType, Parameter)
		
		/// An error indicating that given sealed parameter has a noncapability value type.
		case noncapabilitySealedParameter(Parameter)
		
		/// An error indicating that a value cannot be casted.
		case incompatibleStructuralTypes(castedValue: Value, sourceType: ValueType, targetType: ValueType)
		
		/// An error indicating that the type of the affirmative value is not equal to the type of the negative value.
		case branchTypeMismatch(affirmative: ValueType, negative: ValueType)
		
		// See protocol.
		var errorDescription: String? {
			switch self {
				
				case .undefinedSymbol(let name):
				return "“\(name)” is not defined"
				
				case .notAnUnsealedRecord(let value):
				return "\(value) is not an unsealed record"
				
				case .unknownFieldName(let fieldName, let recordType, let record):
				return "“\(fieldName)” is not a field of \(record) (\(recordType))"
				
				case .notAnUnsealedVector(let vector):
				return "\(vector) is not an unsealed vector"
				
				case .nonnumericIndex(let index, vector: let vector):
				return "\(index) is nonnumeric and thus cannot be used to index \(vector)"
				
				case .resultTypeMismatch(let result, expected: let expected, actual: let actual):
				return "\(result) evaluates to a value of type \(actual) but it's declared to return a value of type \(expected)"
				
				case .undefinedFunction(let name):
				return "“\(name)” is not a defined function"
				
				case .noncapabilityValue(let value):
				return "\(value) is not a capability"
				
				case .notAnUnsealedSealCapability(let value):
				return "\(value) is not an unsealed seal capability"
				
				case .sealedCapability(let value):
				return "\(value) is an (already) sealed capability"
				
				case .nonnumericOperand(let value):
				return "\(value) is nonnumeric and thus cannot be used in a binary operation"
				
				case .operandTypeMismatch(let lhs, let rhs, let lhsType, let rhsType):
				return "\(lhs) (of type \(lhsType)) and \(rhs) (of type \(rhsType)) are incompatible and thus cannot be used together in a binary operation"
				
				case .nonfunctionValue(let value):
				return "\(value) is not a function"
				
				case .argumentTypeMismatch(let value, let valueType, let parameter):
				return "\(value) is of type \(valueType) and thus cannot be used for \(parameter)"
				
				case .noncapabilitySealedParameter(let parameter):
				return "\(parameter) is sealed but doesn't take capabilities"
				
				case .incompatibleStructuralTypes(castedValue: let value, sourceType: let sourceType, targetType: let targetType):
				return "\(value) is of type \(sourceType) which cannot be casted to \(targetType)"
				
				case .branchTypeMismatch(affirmative: let affirmative, negative: let negative):
				return "\(affirmative) and \(negative) have differing types"
				
			}
		}
		
	}
	
}
