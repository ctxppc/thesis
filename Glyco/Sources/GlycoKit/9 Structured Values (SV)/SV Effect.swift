// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

extension SV {
	
	/// An effect on an SV machine.
	public enum Effect : ComposableEffect, Codable, Equatable, SimplyLowerable {
		
		/// An effect that performs `effects`.
		case `do`([Effect])
		
		/// An effect that retrieves the value from given source and puts it in given location.
		case set(Location, to: Source)
		
		/// An effect that computes `lhs` `operation` `rhs` and puts it in `to`.
		case compute(Source, BinaryOperator, Source, to: Location)
		
		/// An effect that pushes a record of given type to the call frame and puts a capability for that record in given location.
		case allocateRecord(RecordType, into: Location)
		
		/// An effect that retrieves the field with given name in the record in `of` and puts it in `to`.
		case getField(RecordType.Field.Name, of: Location, to: Location)
		
		/// An effect that evaluates `to` and puts it in the field with given name in the record in `of`.
		case setField(RecordType.Field.Name, of: Location, to: Source)
		
		/// An effect that pushes a vector of `count` elements of given value type to the call frame and puts a capability for that vector in given location.
		case allocateVector(ValueType, count: Int = 1, into: Location)
		
		/// An effect that retrieves the element at zero-based position `index` in the vector in `of` and puts it in `to`.
		case getElement(of: Location, index: Source, to: Location)
		
		/// An effect that evaluates `to` and puts it in the vector in `of` at zero-based position `index`.
		case setElement(of: Location, index: Source, to: Source)
		
		/// An effect that performs `then` if the predicate holds, or `else` otherwise.
		indirect case `if`(Predicate, then: Effect, else: Effect)
		
		/// An effect that retrieves the value from given source and pushes it to the call frame.
		case push(Source)
		
		/// An effect that removes `bytes` bytes from the stack.
		case pop(bytes: Int)
		
		/// Pushes a new scope to the scope stack.
		///
		/// This effect protects callee-saved physical locations (registers and frame locations) from the previous scope that may be defined in the new scope.
		///
		/// This effect must be executed exactly once before any location defined in the current scope is accessed.
		case pushScope
		
		/// Pops a scope from the scope stack.
		///
		/// This effect restores physical locations (registers and frame locations) previously saved using `pushScope(_:)`.
		///
		/// This effect must be executed exactly once before any location defined in the previous scope is accessed.
		case popScope
		
		/// An effect that invokes the labelled procedure and uses given locations.
		///
		/// This effect assumes a suitable calling convention has already been applied to the program. The locations are only used for the purposes of liveness analysis.
		case call(Label, [Location])
		
		/// An effect that returns to the caller.
		case `return`
		
		// See protocol.
		@EffectBuilder<Lower.Effect>
		func lowered(in context: inout Context) throws -> Lower.Effect {
			switch self {
				
				case .do(let effects):
				Lowered.do(try effects.lowered(in: &context))
				
				case .set(let destination, to: let source):
				Lowered.set(destination, to: source)
				
				case .compute(let lhs, let operation, let rhs, to: let destination):
				Lowered.compute(lhs, operation, rhs, to: destination)
				
				case .allocateRecord(let recordType, into: let record):
				context.recordTypesByRecordLocation[record] = recordType
				Lowered.allocateBuffer(bytes: recordType.byteSize, into: record)
				
				case .getField(let name, of: let record, to: let destination):
				if let recordType = context.recordTypesByRecordLocation[record] {
					if let field = recordType.field(named: name) {
						Lowered.getElement(
							field.valueType.lowered(),
							of:		record,
							offset:	.constant(recordType.byteOffset(of: field)),
							to:		destination
						)
					} else {
						throw LoweringError.unknownFieldName(name, record, recordType)
					}
				} else {
					throw LoweringError.noRecordType(record)
				}
				
				case .setField(let name, of: let record, to: let source):
				if let recordType = context.recordTypesByRecordLocation[record] {
					if let field = recordType.field(named: name) {
						Lowered.setElement(
							field.valueType.lowered(),
							of:		record,
							offset:	.constant(recordType.byteOffset(of: field)),
							to:		source
						)
					} else {
						throw LoweringError.unknownFieldName(name, record, recordType)
					}
				} else {
					throw LoweringError.noRecordType(record)
				}
				
				case .allocateVector(let elementType, count: let count, into: let vector):
				Lowered.allocateBuffer(bytes: elementType.byteSize * count, into: vector)
				
				case .getElement(of: let vector, index: let index, to: let destination):
				if let elementType = context.elementTypesByVectorLocation[vector] {
					let offset = context.locations.uniqueName(from: "offset")
					Lowered.compute(index, .sll, .constant(1 << elementType.byteSize.trailingZeroBitCount), to: .abstract(offset))
					Lowered.getElement(elementType.lowered(), of: vector, offset: .abstract(offset), to: destination)
				} else {
					throw LoweringError.noVectorType(vector)
				}
				
				case .setElement(of: let vector, index: let index, to: let source):
				if let elementType = context.elementTypesByVectorLocation[vector] {
					let offset = context.locations.uniqueName(from: "offset")
					Lowered.compute(index, .sll, .constant(1 << elementType.byteSize.trailingZeroBitCount), to: .abstract(offset))
					Lowered.setElement(elementType.lowered(), of: vector, offset: .abstract(offset), to: source)
				} else {
					throw LoweringError.noVectorType(vector)
				}
				
				case .if(let predicate, then: let affirmative, else: let negative):
				try Lowered.if(predicate.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .push(let source):
				Lowered.push(source)
				
				case .pop(bytes: let bytes):
				Lowered.pop(bytes: bytes)
				
				case .pushScope:
				Lowered.pushScope
				
				case .popScope:
				Lowered.popScope
				
				case .call(let name, let parameters):
				Lowered.call(name, parameters)
				
				case .return:
				Lowered.return
				
			}
		}
		
		// See protocol.
		var subeffects: [Self]? {
			guard case .do(let subeffects) = self else { return nil }
			return subeffects
		}
		
		enum LoweringError : LocalizedError {
			
			/// An error indicating that no record type is known for given location.
			case noRecordType(Location)
			
			/// An error indicating that given field name isn't part of the record type for given location.
			case unknownFieldName(RecordType.Field.Name, Location, RecordType)
			
			/// An error indicating that no vector type is known for given location.
			case noVectorType(Location)
			
			// See protocol.
			var errorDescription: String? {
				switch self {
					
					case .noRecordType(let record):
					return "“\(record)” is not a record"
					
					case .unknownFieldName(let name, let record, let recordType):
					return "“\(record)” of type \(recordType) does not have a field named “\(name)”"
					
					case .noVectorType(let vector):
					return "“\(vector)” is not a vector"
					
				}
			}
			
		}
		
	}
	
}