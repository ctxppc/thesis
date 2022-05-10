// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation
import Sisp

extension EX {
	
	public enum Value : PartiallyStringCodable, PartiallyIntCodable, SimplyLowerable, Element {
		
		/// A value that evaluates to given number.
		case constant(Int)
		
		/// A value that evaluates to the named value associated with given name in the environment.
		case named(Symbol)
		
		/// A value that evaluates to a unique capability to a record with given entries.
		indirect case record([RecordEntry])
		
		/// A value that evaluates to the field with given name in the record `of`.
		indirect case field(Field.Name, of: Value)
		
		/// A value that evaluates to a unique capability to a vector of `count` copies of given value.
		indirect case vector(Value, count: Int)
		
		/// A value that evaluates to the `at`th element of the list `of`.
		indirect case element(of: Value, at: Value)
		
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
		
		/// A value that evaluates to the value of `then` if the predicate holds, or to the value of `else` otherwise.
		indirect case `if`(Predicate, then: Value, else: Value)
		
		/// A value that evaluates to given value after associating zero or more values with a name.
		indirect case `let`([Definition], in: Value)
		
		/// A value that evaluates to given value after performing given effects.
		indirect case `do`([Effect], then: Value)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Value {
			switch self {
				
				case .constant(let value):
				return .source(.constant(value))
					
				case .named(let symbol):
				return .source(.named(symbol))
				
				case .record(let entries):
				let rec: Lower.Symbol = "ex.rec"
				let valueBindings: [(Field.Name, Lower.Symbol, Lower.Value)] = try entries.compactMap { entry in
					guard entry.value != .constant(0) else { return nil }
					return (entry.name, "ex.field.\(entry.name)", try entry.value.lowered(in: &context))
				}
				return .let(
					[.init(rec, .record(.init(try entries.map { .init($0.name, try $0.value.type(in: context)) })))]
						+ valueBindings.map { .init($0.1, $0.2) },
					in: .do(
						valueBindings.map { .setField($0.0, of: rec, to: .named($0.1)) },
						then: .source(.named(rec))
					)
				)
				
				case .field(let fieldName, of: let record):
				let rec = context.symbols.uniqueName(from: "rec")
				return try .let([
					.init(rec, record.lowered(in: &context)),
				], in: .field(fieldName, of: rec))
				
				case .vector(.constant(0), count: let count):
				return .vector(.s32, count: count)
				
				case .vector(let repeatedElement, count: let count):
				let vec: Lower.Symbol = "ex.vec"
				let elem: Lower.Symbol = "ex.elem"
				return try .let(
					[
						.init(vec, .vector(repeatedElement.type(in: context), count: count)),
						.init(elem, repeatedElement.lowered(in: &context)),
					], in: .do(
						(0..<count).map { index in .setElement(of: vec, at: .constant(index), to: .named(elem)) },
						then: .source(.named(vec))
					)
				)
				
				case .element(of: let vector, at: let index):
				let vec = context.symbols.uniqueName(from: "vec")
				let idx = context.symbols.uniqueName(from: "idx")
				return try .let([
					.init(vec, vector.lowered(in: &context)),
					.init(idx, index.lowered(in: &context)),
				], in: .element(of: vec, at: .named(idx)))
				
				case .function(let name):
				return .source(.function(name))
				
				case .seal:
				return .seal
				
				case .sealed(let cap, with: let seal):
				let c = context.symbols.uniqueName(from: "cap")
				let s = context.symbols.uniqueName(from: "seal")
				return try .let([
					.init(c, cap.lowered(in: &context)),
					.init(s, seal.lowered(in: &context)),
				], in: .sealed(c, with: s))
				
				case .binary(let lhs, let op, let rhs):
				let l = context.symbols.uniqueName(from: "lhs")
				let r = context.symbols.uniqueName(from: "rhs")
				return try .let([
					.init(l, lhs.lowered(in: &context)),
					.init(r, rhs.lowered(in: &context)),
				], in: .binary(.named(l), op, .named(r)))
				
				case .evaluate(.function(let name), let arguments):
				let definitions = try arguments.map {
					Lower.Definition(context.symbols.uniqueName(from: "arg"), try $0.lowered(in: &context))
				}
				return .let(definitions, in: .evaluate(.function(name), definitions.map { .named($0.name) }))
				
				case .evaluate(let function, let arguments):
				let f = context.symbols.uniqueName(from: "f")
				let definitions = try arguments.map {
					Lower.Definition(context.symbols.uniqueName(from: "arg"), try $0.lowered(in: &context))
				}
				return .let(
					definitions + [.init(f, try function.lowered(in: &context))],
					in: .evaluate(.named(f), definitions.map { .named($0.name) })
				)
				
				case .if(let predicate, then: let affirmative, else: let negative):
				return try .if(predicate.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .let(let definitions, in: let body):
				let loweredValue = try Lowered.let(definitions.lowered(in: &context), in: body.lowered(in: &context))
				for definition in definitions {	// doesn't matter in which order
					context.undeclare(definition.name)
				}
				return loweredValue
				
				case .do(let effects, then: let value):
				return try .do(effects.lowered(in: &context), then: value.lowered(in: &context))
				
			}
		}
		
		/// Determines the type of `self`.
		func type(in context: Context) throws -> ValueType {
			switch self {
				
				case .constant:
				return .s32
					
				case .named(let symbol):
				guard let type = context.type(of: symbol) else { throw TypingError.undefinedSymbol(symbol) }
				return type
				
				case .record(let entries):
				return .cap(.record(.init(try entries.map { try .init($0.name, $0.value.type(in: context)) }), sealed: false))
				
				case .field(let fieldName, of: let record):
				guard case .cap(.record(let recordType, sealed: false)) = try record.type(in: context) else { throw TypingError.notAnUnsealedRecord(record) }
				guard let fieldType = recordType.fields[fieldName]?.valueType else { throw TypingError.unknownFieldName(fieldName, recordType, record) }
				return fieldType
				
				case .vector(let repeatedElement, count: _):
				return .cap(.vector(of: try repeatedElement.type(in: context), sealed: false))
				
				case .element(of: let vector, at: _):
				guard case .cap(.vector(of: let elementType, sealed: false)) = try vector.type(in: context) else { throw TypingError.notAnUnsealedRecord(vector) }
				return elementType
				
				case .function(let name):
				guard let function = context.functions[name] else { throw TypingError.undefinedFunction(name) }
				return .cap(.function(takes: function.parameters, returns: function.resultType))
				
				case .seal:
				return .cap(.seal(sealed: false))
				
				case .sealed(let cap, with: let seal):
				guard case .cap(let capType) = try cap.type(in: context) else { throw TypingError.noncapabilityValue(cap) }
				guard case .cap(.seal(sealed: false)) = try seal.type(in: context) else { throw TypingError.notAnUnsealedSealCapability(cap) }
				switch capType {
					
					case .vector(of: let elementType, sealed: false):
					return .cap(.vector(of: elementType, sealed: true))
					
					case .record(let recordType, sealed: false):
					return .cap(.record(recordType, sealed: true))
					
					case .function:
					return .cap(capType)
					
					case .seal(sealed: false):
					return .cap(.seal(sealed: true))
					
					case .vector(of: _, sealed: true),
						.record(_, sealed: true),
						.seal(sealed: true):
					throw TypingError.sealedCapability(cap)
					
				}
				
				case .binary:
				return .s32
				
				case .evaluate(let function, _):
				guard case .cap(.function(takes: _, returns: let resultType)) = try function.type(in: context) else {
					throw TypingError.nonfunctionValue(function)
				}
				return resultType
				
				case .if(_, then: let affirmative, else: _):
				return try affirmative.type(in: context)
				
				case .let(let definitions, in: let body):
				var context = context
				for definition in definitions {
					context.declare(definition.name, try definition.value.type(in: context))
				}
				return try body.type(in: context)
				
				case .do(_, then: let value):
				return try value.type(in: context)
				
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
		
		/// An error indicating that a function with given name is not defined.
		case undefinedFunction(Label)
		
		/// An error indicating that given value is not an unsealed capability.
		case noncapabilityValue(Value)
		
		/// An error indicating that given value is not an unsealed seal capability.
		case notAnUnsealedSealCapability(Value)
		
		/// An error indicating that given value is a sealed capability.
		case sealedCapability(Value)
		
		/// An error indicating that given value is not a function that can be evaluated.
		case nonfunctionValue(Value)
		
		// See protocol.
		var errorDescription: String? {
			switch self {
				
				case .undefinedSymbol(let name):
				return "“\(name)” is not defined"
				
				case .notAnUnsealedRecord(let value):
				return "\(value) is not an unsealed record"
				
				case .unknownFieldName(let fieldName, let recordType, let record):
				return "“\(fieldName)” is not a field of \(record) (\(recordType))"
				
				case .undefinedFunction(let name):
				return "“\(name)” is not a defined function"
				
				case .noncapabilityValue(let value):
				return "\(value) is not a capability"
				
				case .notAnUnsealedSealCapability(let value):
				return "\(value) is not an unsealed seal capability"
				
				case .sealedCapability(let value):
				return "\(value) is an (already) sealed capability"
				
				case .nonfunctionValue(let value):
				return "\(value) is not a function"
				
			}
		}
		
	}
	
}
