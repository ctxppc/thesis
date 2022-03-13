// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

extension SV {
	
	/// An effect on an SV machine.
	public enum Effect : ComposableEffect, Codable, Equatable, SimplyLowerable {
		
		/// An effect that performs `effects`.
		case `do`([Effect])
		
		/// An effect that retrieves the value from given source and puts it in given location.
		case set(Location, to: Source)
		
		/// An effect that computes given expression and puts the result in given location.
		case compute(Location, Source, BinaryOperator, Source)
		
		/// An effect that creates an (uninitialised) record of given type and puts a capability for that record in given location.
		///
		/// If `scoped` is `true`, the record may be destroyed when the current scope is popped and must not be accessed afterwards.
		case createRecord(RecordType, capability: Location, scoped: Bool)
		
		/// An effect that retrieves the field with given name in the record in `of` and puts it in `to`.
		case getField(RecordType.Field.Name, of: Location, to: Location)
		
		/// An effect that evaluates `to` and puts it in the field with given name in the record in `of`.
		case setField(RecordType.Field.Name, of: Location, to: Source)
		
		/// An effect that creates an (uninitialised) vector of `count` elements of given value type and puts a capability for that vector in given location.
		///
		/// If `scoped` is `true`, the vector may be destroyed when the current scope is popped and must not be accessed afterwards.
		case createVector(ValueType, count: Int = 1, capability: Location, scoped: Bool)
		
		/// An effect that retrieves the element at zero-based position `index` in the vector in `of` and puts it in `to`.
		case getElement(of: Location, index: Source, to: Location)
		
		/// An effect that evaluates `to` and puts it in the vector in `of` at zero-based position `index`.
		case setElement(of: Location, index: Source, to: Source)
		
		/// An effect that destroys the scoped vector or record referred to by the capability from given source.
		///
		/// This effect must only be used with *scoped* values created in the *current* scope. For any two values *a* and *b* created in the current scope, *b* must be destroyed exactly once before destroyed *a*. Destruction is not required before popping the scope; in that case, destruction is automatic.
		case destroyScopedValue(capability: Source)
		
		/// An effect that performs `then` if the predicate holds, or `else` otherwise.
		indirect case `if`(Predicate, then: Effect, else: Effect)
		
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
		
		/// An effect that clears all registers except the structural registers `csp`, `cgp`, `ctp`, and `cfp` as well as given registers.
		case clearAll(except: [Register])
		
		/// An effect that calls the procedure with given name and uses given parameter registers.
		///
		/// This effect assumes a suitable calling convention has already been applied to the program. The parameter registers are only used for the purposes of liveness analysis.
		case call(Label, parameters: [Register])
		
		/// An effect that jumps to the address in `target` after unsealing it, and puts the datum in `data` in `invocationData` after unsealing it.
		case invoke(target: Source, data: Source)
		
		/// An effect that returns to the caller.
		case `return`
		
		// See protocol.
		@EffectBuilder<Lower.Effect>
		func lowered(in context: inout Context) throws -> Lower.Effect {
			switch self {
				
				case .do(let effects):
				Lowered.do(try effects.lowered(in: &context))
				
				case .set(let destination, to: .register(let register, .vectorCap(let elementType))):
				context.elementTypesByVectorLocation[destination] = elementType
				Lowered.set(destination, to: .register(register, .cap))
				
				case .set(let destination, to: .register(let register, .recordCap(let recordType))):
				context.recordTypesByRecordLocation[destination] = recordType
				Lowered.set(destination, to: .register(register, .cap))
				
				case .set(let destination, to: let source):
				if let location = source.location {
					if let elementType = context.elementTypesByVectorLocation[location] {
						context.elementTypesByVectorLocation[destination] = elementType
					} else if let recordType = context.recordTypesByRecordLocation[location] {
						context.recordTypesByRecordLocation[destination] = recordType
					}
				}
				Lowered.set(destination, to: try source.lowered(in: &context))
				
				case .compute(let destination, let lhs, let operation, let rhs):
				try Lowered.compute(destination, lhs.lowered(in: &context), operation, rhs.lowered(in: &context))
				
				case .createRecord(let recordType, capability: let record, scoped: let scoped):
				context.recordTypesByRecordLocation[record] = recordType
				Lowered.createBuffer(bytes: recordType.byteSize, capability: record, scoped: scoped)
				
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
							to:		try source.lowered(in: &context)
						)
					} else {
						throw LoweringError.unknownFieldName(name, record, recordType)
					}
				} else {
					throw LoweringError.noRecordType(record)
				}
				
				case .createVector(let elementType, count: let count, capability: let vector, scoped: let scoped):
				Lowered.createBuffer(bytes: elementType.byteSize * count, capability: vector, scoped: scoped)
				
				case .getElement(of: let vector, index: let index, to: let destination):
				if let elementType = context.elementTypesByVectorLocation[vector] {
					let offset = context.locations.uniqueName(from: "offset")
					Lowered.compute(.abstract(offset), try index.lowered(in: &context), .sll, .constant(1 << elementType.byteSize.trailingZeroBitCount))
					Lowered.getElement(elementType.lowered(), of: vector, offset: .abstract(offset), to: destination)
				} else {
					throw LoweringError.noVectorType(vector)
				}
				
				case .setElement(of: let vector, index: let index, to: let source):
				if let elementType = context.elementTypesByVectorLocation[vector] {
					let offset = context.locations.uniqueName(from: "offset")
					Lowered.compute(.abstract(offset), try index.lowered(in: &context), .sll, .constant(1 << elementType.byteSize.trailingZeroBitCount))
					Lowered.setElement(elementType.lowered(), of: vector, offset: .abstract(offset), to: try source.lowered(in: &context))
				} else {
					throw LoweringError.noVectorType(vector)
				}
				
				case .destroyScopedValue(capability: let capability):
				Lowered.destroyBuffer(capability: try capability.lowered(in: &context))
				
				case .if(let predicate, then: let affirmative, else: let negative):
				try Lowered.if(predicate.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .pushScope:
				Lowered.pushScope
				
				case .popScope:
				Lowered.popScope
				
				case .clearAll(except: let sparedRegisters):
				Lowered.clearAll(except: sparedRegisters)
				
				case .call(let name, let parameters):
				Lowered.call(name, parameters: parameters)
				
				case .invoke(target: let target, data: let data):
				try Lowered.invoke(target: target.lowered(in: &context), data: data.lowered(in: &context))
				
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
