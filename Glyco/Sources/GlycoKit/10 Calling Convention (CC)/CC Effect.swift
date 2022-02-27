// Glyco © 2021–2022 Constantino Tsarouhas

import DepthKit
import Foundation

extension CC {
	
	/// An effect on a CC machine.
	public enum Effect : ComposableEffect, Codable, Equatable, SimplyLowerable {
		
		/// An effect that performs `effects`.
		case `do`([Effect])
		
		/// An effect that retrieves the value from given source and puts it in given location.
		case set(Location, to: Source)
		
		/// An effect that computes given expression and puts the result in given location.
		case compute(Location, Source, BinaryOperator, Source)
		
		/// An effect that pushes a record of given type to the current scope and puts a capability for that record in given location.
		case pushRecord(RecordType, capability: Location)
		
		/// An effect that retrieves the field with given name in the record in `of` and puts it in `to`.
		case getField(RecordType.Field.Name, of: Location, to: Location)
		
		/// An effect that evaluates `to` and puts it in the field with given name in the record in `of`.
		case setField(RecordType.Field.Name, of: Location, to: Source)
		
		/// An effect that pushes a vector of `count` elements of given value type to the current scope and puts a capability for that vector in given location.
		case pushVector(ValueType, count: Int = 1, capability: Location)
		
		/// An effect that retrieves the element at zero-based position `index` in the vector in `of` and puts it in `to`.
		case getElement(of: Location, index: Source, to: Location)
		
		/// An effect that evaluates `to` and puts it in the vector in `of` at zero-based position `index`.
		case setElement(of: Location, index: Source, to: Source)
		
		/// An effect that pops the vector or record referred by the capability from given source.
		///
		/// This effect must only be used with values allocated in the current scope. For any two values *a* and *b* allocated in the current scope, *b* must be deallocated exactly once before deallocating *a*. Deallocation is not required before returning; in that case, deallocation is automatic.
		case popValue(capability: Source)
		
		/// An effect that performs `then` if the predicate holds, or `else` otherwise.
		indirect case `if`(Predicate, then: Effect, else: Effect)
		
		/// An effect that invokes the labelled procedure passing given arguments and puts the procedure's result in `result`.
		case call(Label, [Source], result: Location)
		
		/// An effect that returns given result to the caller.
		///
		/// This effect also pops any values pushed to the current scope.
		case `return`(Source)
		
		// See protocol.
		@EffectBuilder<Lowered>
		func lowered(in context: inout Context) throws -> Lower.Effect {
			switch self {
				
				case .do(let effects):
				Lowered.do(try effects.lowered(in: &context))
				
				case .set(let location, to: let source):
				Lowered.set(.abstract(location), to: try source.lowered(in: &context))
				
				case .compute(let destination, let lhs, let op, let rhs):
				try Lowered.compute(.abstract(destination), lhs.lowered(in: &context), op, rhs.lowered(in: &context))
				
				case .pushRecord(let type, capability: let record):
				Lowered.pushRecord(type, capability: .abstract(record))
				
				case .getField(let fieldName, of: let record, to: let destination):
				Lowered.getField(fieldName, of: .abstract(record), to: .abstract(destination))
				
				case .setField(let fieldName, of: let record, to: let source):
				Lowered.setField(fieldName, of: .abstract(record), to: try source.lowered(in: &context))
				
				case .pushVector(let type, count: let count, capability: let vector):
				Lowered.pushVector(type, count: count, capability: .abstract(vector))
				
				case .getElement(of: let vector, index: let index, to: let destination):
				Lowered.getElement(of: .abstract(vector), index: try index.lowered(in: &context), to: .abstract(destination))
				
				case .setElement(of: let vector, index: let index, to: let source):
				try Lowered.setElement(of: .abstract(vector), index: index.lowered(in: &context), to: source.lowered(in: &context))
				
				case .popValue(capability: let capability):
				Lowered.popValue(capability: try capability.lowered(in: &context))
				
				case .if(let predicate, then: let affirmative, else: let negative):
				try Lowered.if(predicate.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .call(let name, let arguments, result: let result):
				if let procedure = context.procedures[name] {
					
					// Prepare assignments.
					let assignments = procedure.parameterAssignments(in: context.configuration)
					
					// Allocate arguments record, if nonempty.
					let argumentsRecord = context.locations.uniqueName(from: "args")
					if !assignments.parameterRecordType.isEmpty {
						Lowered.pushRecord(assignments.parameterRecordType, capability: .abstract(argumentsRecord))
					}
					
					// Prepare arguments for lowering.
					let arguments = try arguments.lowered(in: &context)
					let parameterNames = procedure.parameters.map(\.location.rawValue)
					let argumentsByParameterName = Dictionary(uniqueKeysWithValues: zip(parameterNames, arguments))
					
					// Pass frame-resident arguments first.
					for field in assignments.parameterRecordType {
						Lowered.setField(field.name, of: .abstract(argumentsRecord), to: argumentsByParameterName[field.name.rawValue] !! "Missing argument")
					}
					
					// Pass register-resident arguments last to limit liveness range of registers.
					for (asn, arg) in zip(assignments.viaRegisters, arguments) {
						Lowered.set(.register(asn.register), to: arg)
					}
					
					// Invoke procedure.
					// Parameter registers are considered in use but no frame locations are used since frame-res. args. are passed via an allocated record.
					Lowered.call(name, parameters: assignments.viaRegisters.map(\.register))
					
					// Deallocate frame-resident arguments, if any.
					if !assignments.parameterRecordType.isEmpty {
						Lowered.popValue(capability: .abstract(argumentsRecord))
					}
					
					// Write result.
					Lowered.set(.abstract(result), to: .register(.a0, procedure.resultType))
					
				} else {
					throw LoweringError.unrecognisedProcedure(name: name)
				}
				
				case .return(let result):
				do {
					
					// Write result to a0.
					Lowered.set(.register(.a0), to: try result.lowered(in: &context))
					// TODO: Write to a global abstract location to ensure consistent return type, and infer return type from that.
					
					// If lowering a procedure, copy callee-saved registers (except fp) back from abstract locations (reverse of prologue).
					if context.loweredProcedure != nil {
						for register in Lower.Register.calleeSavedRegistersInCHERIRVABI {
							Lowered.set(.register(register), to: .abstract(context.calleeSaveLocation(for: register)))
						}
					}
					
					// We're done.
					Lowered.popScope
					Lowered.return
					
				}
				
			}
		}
		
		enum LoweringError : LocalizedError {
			
			/// An error indicating that no procedure is known by the name `name`.
			case unrecognisedProcedure(name: Label)
			
			// See protocol.
			var errorDescription: String? {
				switch self {
					case .unrecognisedProcedure(name: let name):
					return "No procedure is known by the name “\(name)”."
				}
			}
			
		}
		
		// See protocol.
		var subeffects: [Self]? {
			guard case .do(let subeffects) = self else { return nil }
			return subeffects
		}
		
	}
	
}
