// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

extension NT {
	
	public enum Value : Codable, Equatable, SimplyLowerable {
		
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
		/// The vector may be of a nominal type. The index must be a (structural) `s32` value.
		indirect case element(of: Value, at: Value)
		
		/// A value that evaluates to an anonymous function with given parameters, result type, and result.
		indirect case λ(takes: [Parameter], returns: ValueType, in: Result)
		
		/// A value representing a globally defined function with given name.
		case function(Label)
		
		/// A value that evaluates to a unique capability that can be used for sealing.
		case seal
		
		/// A value that evaluates to the first capability after sealing it with the (second) seal capability.
		indirect case sealed(Value, with: Value)
		
		/// A value that evaluates to *x* *op* *y* where *x* and *y* are given sources and *op* is given operator.
		indirect case binary(Value, BinaryOperator, Value)
		
		/// A value that evaluates to given function evaluated with given arguments.
		indirect case evaluate(Value, [Value])
		
		/// A value that evaluates to given value but is typed as the type with given name, ignoring nominal typing rules.
		indirect case cast(Value, as: TypeName)
		
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
		func valueType(in context: TypingContext) throws -> ValueType {
			switch self {
				
				case .constant:
				return .s32
					
				case .named(let symbol):
				guard let type = context.valueTypesBySymbol[symbol] else { throw TypingError.undefinedSymbol(symbol) }
				return type
				
				case .record(let type):
				return .cap(.record(type, sealed: false))
				
				case .field(let fieldName, of: let record):
				guard case .cap(.record(let recordType, sealed: false)) = try record.structuralValueType(in: context) else {
					throw TypingError.notAnUnsealedRecord(record)
				}
				guard let field = recordType.fields[fieldName] else {
					throw TypingError.unknownFieldName(fieldName, recordType, record)
				}
				return field.valueType
				
				case .vector(let elementType, count: _):
				return .cap(.vector(of: elementType, sealed: false))
				
				case .element(of: let vector, at: let index):
				guard case .cap(.vector(of: let elementType, sealed: false)) = try vector.structuralValueType(in: context) else {
					throw TypingError.notAnUnsealedVector(vector)
				}
				guard try index.normalisedValueType(in: context) == .s32 else { throw TypingError.nonnumericIndex(index, vector: vector) }
				return elementType
				
				case .λ(takes: let parameters, returns: let resultType, in: let result):
				let normalisedDeclaredResultType = try resultType.normalised(in: context)
				var bodyContext = context
				bodyContext.valueTypesBySymbol = .init(uniqueKeysWithValues: try parameters.map { parameter in
					if parameter.sealed {
						guard case .cap(let capType) = parameter.type else { throw TypingError.noncapabilitySealedParameter(parameter) }
						return (parameter.name, .cap(capType.sealed(false)))
					} else {
						return (parameter.name, parameter.type)
					}
				})
				let normalisedActualResultType = try result.normalisedValueType(in: bodyContext)
				guard normalisedActualResultType == normalisedDeclaredResultType else { throw TypingError.resultTypeMismatch(result, expected: normalisedDeclaredResultType, actual: normalisedActualResultType) }
				return .cap(.function(takes: parameters, returns: resultType))
				
				case .function(let name):
				guard let function = context.functions[name] else { throw TypingError.undefinedFunction(name) }
				return .cap(.function(takes: function.parameters, returns: function.resultType))
				
				case .seal:
				return .cap(.seal(sealed: false))
				
				case .sealed(let cap, with: let seal):
				guard case .cap(let capType) = try cap.normalisedValueType(in: context) else { throw TypingError.noncapabilityValue(cap) }
				guard case .cap(.seal(sealed: false)) = try seal.normalisedValueType(in: context) else { throw TypingError.notAnUnsealedSealCapability(cap) }
				switch capType {
					
					case .vector(of: let elementType, sealed: false):
					return .cap(.vector(of: elementType, sealed: true))
					
					case .record(let recordType, sealed: false):
					return .cap(.record(recordType, sealed: true))
					
					case .function:
					return .cap(capType)
					
					case .seal(sealed: false):
					return .cap(.seal(sealed: true))
					
					case .vector(of: _, sealed: true), .record(_, sealed: true), .seal(sealed: true):
					throw TypingError.sealedCapability(cap)
					
				}
				
				case .binary(let lhs, _, let rhs):
				guard try lhs.normalisedValueType(in: context) == .s32 else { throw TypingError.nonnumericOperand(lhs) }
				guard try rhs.normalisedValueType(in: context) == .s32 else { throw TypingError.nonnumericOperand(rhs) }
				return .s32
				
				case .evaluate(let function, let arguments):
				guard case .cap(.function(takes: let parameters, returns: let resultType)) = try function.normalisedValueType(in: context) else {
					throw TypingError.nonfunctionValue(function)
				}
				for (parameter, argument) in zip(parameters, arguments) {
					if try argument.normalisedValueType(in: context) != parameter.type {	// parameter is already normalised in a normalised function type
						throw TypingError.argumentTypeMismatch(argument, parameter)
					}
				}
				return resultType	// result type is already normalised in a normalised function type
				
				case .cast(let value, as: let typeName):
				let sourceType = try value.structuralValueType(in: context)
				let targetType = try ValueType.named(typeName).structural(in: context)
				guard sourceType == targetType else { throw TypingError.incompatibleStructuralTypes(castedValue: value, sourceType: sourceType, targetType: targetType) }
				return .named(typeName)
				
				case .if(_, then: let affirmative, else: let negative):
				// TODO: Type-check predicate?
				let affirmativeType = try affirmative.normalisedValueType(in: context)
				let negativeType = try negative.normalisedValueType(in: context)
				guard affirmativeType == negativeType else { throw TypingError.branchTypeMismatch(affirmative: affirmativeType, negative: negativeType) }
				return affirmativeType
				
				case .let(let definitions, in: let body):
				var context = context
				for definition in definitions {
					context.valueTypesBySymbol[definition.name] = try definition.value.valueType(in: context)
				}
				return try body.valueType(in: context)
				
				case .letType(let definitions, in: let body):
				var context = context
				context.types.append(contentsOf: definitions)
				return try body.valueType(in: context)
				
				case .do(_, then: let value):
				// TODO: Type-check effects?
				return try value.valueType(in: context)
				
			}
		}
		
		/// Determines the normalised type of `self`.
		func normalisedValueType(in context: TypingContext) throws -> ValueType {
			try valueType(in: context).normalised(in: context)
		}
		
		/// Determines the structural type of `self`.
		func structuralValueType(in context: TypingContext) throws -> ValueType {
			try valueType(in: context).structural(in: context)
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
		
		/// An error indicating that given value is not a function that can be evaluated.
		case nonfunctionValue(Value)
		
		/// An error indicating that given argument has the wrong type for given parameter.
		case argumentTypeMismatch(Value, Parameter)
		
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
				
				case .nonfunctionValue(let value):
				return "\(value) is not a function"
				
				case .argumentTypeMismatch(let value, let parameter):
				return "\(value) cannot be used for \(parameter)"
				
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
