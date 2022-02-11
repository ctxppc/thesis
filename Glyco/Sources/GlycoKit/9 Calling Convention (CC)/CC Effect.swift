// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

extension CC {
	
	/// An effect on a CC machine.
	public enum Effect : ComposableEffect, Codable, Equatable, SimplyLowerable {
		
		/// An effect that performs `effects`.
		case `do`([Effect])
		
		/// An effect that retrieves the value from given source and puts it in given location.
		case set(Location, to: Source)
		
		/// An effect that computes `lhs` `operation` `rhs` and puts it in `to`.
		case compute(Source, BinaryOperator, Source, to: Location)
		
		/// An effect that pushes a vector of `count` elements of given data type to the call frame and puts a capability for that vector in `into`.
		case allocateVector(ValueType, count: Int = 1, into: Location)
		
		/// An effect that retrieves the element at zero-based position `at` in the vector in `of` and puts it in `to`.
		case getElement(of: Location, at: Source, to: Location)
		
		/// An effect that evaluates `to` and puts it in the vector in `of` at zero-based position `at`.
		case setElement(of: Location, at: Source, to: Source)
		
		/// An effect that performs `then` if the predicate holds, or `else` otherwise.
		indirect case `if`(Predicate, then: Effect, else: Effect)
		
		/// An effect that invokes the labelled procedure passing given arguments and puts the procedure's result in `result`.
		case call(Label, [Source], result: Location)
		
		/// An effect that returns given result to the caller.
		case `return`(Source)
		
		// See protocol.
		@EffectBuilder<Lowered>
		func lowered(in context: inout Context) throws -> Lower.Effect {
			switch self {
				
				case .do(let effects):
				Lowered.do(try effects.lowered(in: &context))
				
				case .set(let location, to: let source):
				Lowered.set(.abstract(location), to: try source.lowered(in: &context))
				
				case .compute(let lhs, let op, let rhs, to: let destination):
				try Lowered.compute(lhs.lowered(in: &context), op, rhs.lowered(in: &context), to: .abstract(destination))
				
				case .allocateVector(let type, count: let count, into: let vector):
				Lowered.allocateVector(type, count: count, into: .abstract(vector))
				
				case .getElement(of: let vector, at: let index, to: let destination):
				Lowered.getElement(of: .abstract(vector), at: try index.lowered(in: &context), to: .abstract(destination))
				
				case .setElement(of: let vector, at: let index, to: let element):
				try Lowered.setElement(of: .abstract(vector), at: index.lowered(in: &context), to: element.lowered(in: &context))
				
				case .if(let predicate, then: let affirmative, else: let negative):
				try Lowered.if(predicate.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .call(let name, let arguments, result: let result):
				if let procedure = context.procedures[name] {
					
					// Prepare assignments.
					let assignments = procedure.parameterAssignments(in: context.configuration)
					
					// Allocate structure for frame-resident arguments, if there are any.
					// a0 is overwritten with a register-resident arg after all frame-resident args have already been passed, so we can use it freely.
					let argumentsStructure = Lower.Location.register(.a0)
					let argumentsStructureSize = assignments.viaCallFrame.lazy.map(\.parameter).totalByteSize()
					if argumentsStructureSize > 0 {
						Lowered.allocateVector(.byte, count: argumentsStructureSize, into: argumentsStructure)
					}
					
					// Prepare arguments for lowering.
					let arguments = try arguments.lowered(in: &context).makeIterator()
					
					// First arguments go via registers. Consume arguments iterator by eagerly evaluating the zip.
					let assignmentArgumentPairsViaRegisters = Array(zip(assignments.viaRegisters, arguments))
					
					// Remaining arguments go via call frame. Consume arguments iterator by eagerly evaluating the zip.
					let assignmentArgumentPairsViaFrame = Array(zip(assignments.viaCallFrame, arguments))
					
					// Pass frame-resident arguments first.
					for (a, arg) in assignmentArgumentPairsViaFrame {
						Lowered.setElement(a.parameter.type, of: argumentsStructure, at: .constant(a.callerOffset), to: arg)
					}
					
					// Pass register-resident arguments last to limit liveness range of registers.
					for (a, arg) in assignmentArgumentPairsViaRegisters {
						Lowered.set(.register(a.register), to: arg)
					}
					
					// Invoke procedure.
					Lowered.call(name, assignments.viaRegisters.map { .register($0.register) } + assignments.viaCallFrame.map { .frame($0.calleeLocation) })
					
					// Deallocate frame-resident arguments, if any.
					if argumentsStructureSize > 0 {
						Lowered.pop(bytes: argumentsStructureSize)
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
						for register in Lower.Register.defaultCalleeSavedRegisters {
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
