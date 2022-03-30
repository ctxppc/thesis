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
		
		/// An effect that creates a capability that can be used for sealing with a unique object type and puts it in given location.
		case createSeal(in: Location)
		
		/// An effect that seals the capability in `source` using the sealing capability in `seal` and puts it in `into`.
		case seal(into: Location, source: Location, seal: Location)
		
		/// An effect that destroys the scoped vector or record referred to by the capability from given source.
		///
		/// This effect must only be used with *scoped* values created in the *current* scope. For any two values *a* and *b* created in the current scope, *b* must be destroyed exactly once before destroyed *a*. Destruction is not required before popping the scope; in that case, destruction is automatic.
		case destroyScopedValue(capability: Source)
		
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
				
				case .createRecord(let type, capability: let record, scoped: let scoped):
				Lowered.createRecord(type, capability: .abstract(record), scoped: scoped)
				
				case .getField(let fieldName, of: let record, to: let destination):
				Lowered.getField(fieldName, of: .abstract(record), to: .abstract(destination))
				
				case .setField(let fieldName, of: let record, to: let source):
				Lowered.setField(fieldName, of: .abstract(record), to: try source.lowered(in: &context))
				
				case .createVector(let elementType, count: let count, capability: let vector, scoped: let scoped):
				Lowered.createVector(elementType, count: count, capability: .abstract(vector), scoped: scoped)
				
				case .getElement(of: let vector, index: let index, to: let destination):
				Lowered.getElement(of: .abstract(vector), index: try index.lowered(in: &context), to: .abstract(destination))
				
				case .setElement(of: let vector, index: let index, to: let source):
				try Lowered.setElement(of: .abstract(vector), index: index.lowered(in: &context), to: source.lowered(in: &context))
				
				case .destroyScopedValue(capability: let capability):
				Lowered.destroyScopedValue(capability: try capability.lowered(in: &context))
				
				case .createSeal(in: let seal):
				Lowered.createSeal(in: .abstract(seal))
				
				case .seal(into: let destination, source: let source, seal: let seal):
				Lowered.seal(into: .abstract(destination), source: .abstract(source), seal: .abstract(seal))
				
				case .if(let predicate, then: let affirmative, else: let negative):
				try Lowered.if(predicate.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .call(let name, let arguments, result: let result):
				if let procedure = context.procedures[name] {
					
					// Caller-save registers in abstract locations to limit their liveness across a call.
					if context.configuration.limitsCallerSavedRegisterLifetimes {
						for register in context.configuration.callerSavedRegisters {
							Lower.Effect.set(.abstract(context.saveLocation(for: register)), to: .register(register, .registerDatum))
						}
					}
					
					// Determine assignments.
					let assignments = procedure.parameterAssignments(in: context.configuration)
					
					// Create (scoped) arguments record, if nonempty. (The record is heap-allocated when the call stack is discontiguous.)
					let argumentsRecord = context.locations.uniqueName(from: "args")
					if !assignments.parameterRecordType.isEmpty {
						Lowered.createRecord(assignments.parameterRecordType, capability: .abstract(argumentsRecord), scoped: true)
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
					
					// Pass capability to arguments record, if applicable.
					if let recordRegister = assignments.argumentsRecordRegister {
						Lowered.set(.register(recordRegister), to: .abstract(argumentsRecord))
					}
					
					// If using a secure CC, clear all registers except argument registers in use.
					let argumentRegisters = assignments
						.viaRegisters
						.map(\.register)
						.appending(contentsOf: [assignments.argumentsRecordRegister].compacted())
					if context.configuration.callingConvention != .conventional {
						Lowered.clearAll(except: argumentRegisters)
					}
					
					// Call or scall procedure.
					// Frame locations are not considered "in use" since frame-resident arguments are passed via an allocated record.
					Lowered.call(name, parameters: argumentRegisters)
					
					// Destroy arguments record, if it exists. (This does nothing when the call stack is discontiguous.)
					if !assignments.parameterRecordType.isEmpty {
						Lowered.destroyScopedValue(capability: .abstract(argumentsRecord))
					}
					
					// Write result.
					Lowered.set(.abstract(result), to: .register(.a0, procedure.resultType))
					
					// Restore caller-saved registers from abstract locations.
					if context.configuration.limitsCallerSavedRegisterLifetimes {
						for register in context.configuration.callerSavedRegisters {
							Lowered.set(.register(register), to: .abstract(context.saveLocation(for: register)))
						}
					}
					
				} else {
					throw LoweringError.unrecognisedProcedure(name: name)
				}
				
				case .return(let result):
				do {
					
					// Write result to a0.
					let resultRegister = Lower.Register.a0
					Lowered.set(.register(resultRegister), to: try result.lowered(in: &context))
					// TODO: Write to a global abstract location to ensure consistent return type, and infer return type from that.
					
					// If lowering a procedure, restore assignable callee-saved registers from abstract locations — reverse of prologue.
					if context.loweredProcedure != nil {
						for register in context.configuration.calleeSavedRegisters {
							Lowered.set(.register(register), to: .abstract(context.saveLocation(for: register)))
						}
					}
					
					// Restore return capability from abstract location — the return effect cannot use an abstract location since the scope is popped by then.
					Lowered.set(.register(.ra), to: .abstract(context.returnLocation))
					
					// If using a secure CC, clear all registers except for the result value and sealed return–frame capabilities.
					if context.configuration.callingConvention != .conventional {
						Lowered.clearAll(except: [resultRegister, .ra])
					}
					
					// Pop scope.
					Lowered.popScope
					
					// Return.
					Lowered.return(to: .register(.ra, .codeCap))
					
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
