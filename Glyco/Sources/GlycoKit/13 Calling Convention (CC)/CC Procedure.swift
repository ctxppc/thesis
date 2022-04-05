// Glyco © 2021–2022 Constantino Tsarouhas

import Algorithms
import DepthKit

extension CC {
	
	/// A program element that can be invoked by name.
	public struct Procedure : Codable, Equatable, Named, SimplyLowerable {
		
		/// Creates a procedure with given name, parameters, result type, and effect.
		public init(_ name: Label, takes parameters: [Parameter], returns resultType: ValueType, in effect: Effect) {
			self.name = name
			self.parameters = parameters
			self.resultType = resultType
			self.effect = effect
		}
		
		/// The name with which the procedure can be invoked.
		public var name: Label
		
		/// The procedure's parameters.
		public var parameters: [Parameter]
		
		/// The procedure's result type.
		public var resultType: ValueType
		
		/// The procedure's effect when invoked.
		public var effect: Effect
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Procedure {
			
			let previousProcedure = context.loweredProcedure
			context.loweredProcedure = self
			defer { context.loweredProcedure = previousProcedure }
			
			return .init(name, in: try .do {
				
				// Prepare new scope.
				Lower.Effect.pushScope
				
				// Bind assignable callee-saved registers to abstract locations to limit their liveness.
				for register in context.configuration.calleeSavedRegisters {
					Lower.Effect.set(.abstract(context.saveLocation(for: register)), to: .register(register, .registerDatum))
				}
				
				// Bind return capability.
				Lower.Effect.set(.abstract(context.returnLocation), to: .register(.ra, .cap(.code)))
				
				// Determine parameter assignments.
				let assignments = parameterAssignments(in: context.configuration)
				
				// Bind local names to register-resident arguments — limit liveness ranges by using the registers as early as possible.
				// Sealed parameters are passed as part of the sealed invocation effect instead.
				for asn in assignments.viaRegisters where !asn.parameter.sealed {
					let parameter = asn.parameter
					Lower.Effect.set(.abstract(parameter.location), to: .register(asn.register, parameter.type.lowered()))
				}
				
				// Bind local names to arguments in arguments record.
				// If arguments record capability is available, load from record; otherwise load from call frame.
				var parameterRecordType = assignments.parameterRecordType
				if let argumentsRecordRegister = assignments.argumentsRecordRegister {
					for field in parameterRecordType {
						Lower.Effect.getField(
							field.name,
							of: .register(argumentsRecordRegister),
							to: .abstract(.init(rawValue: field.name.rawValue))
						)
					}
				} else {
					parameterRecordType.prependOrReplace(.init("cc.__savedfp__", .cap(.vector(of: .u8, sealed: false))))
					for (field, offset) in parameterRecordType.fieldByteOffsetPairs().dropFirst() {
						Lower.Effect.set(.abstract(.init(rawValue: field.name.rawValue)), to: .frame(.init(offset: offset)))
					}
				}
				
				// Execute main effect.
				try effect.lowered(in: &context)
				
			})
			
		}
		
		/// Returns the assignments of the procedure's parameters to physical locations.
		func parameterAssignments(in configuration: CompilationConfiguration) -> Parameter.Assignments {
			
			// Prepare empty assignment.
			var assignments = Parameter.Assignments()
			
			// Assign sealed parameter (if any) to invocation data register.
			var parameters = self.parameters[...]
			if let index = parameters.firstIndex(where: \.sealed) {
				assignments.viaRegisters.append(.init(parameter: parameters.remove(at: index), register: .invocationData))
			}
			
			// Prepare available arguments registers.
			var registers = configuration.argumentRegisters[...]
			
			// If a discontiguous call stack is in use and an arguments record is required, reserve a register for the arguments record capability.
			if !configuration.callingConvention.usesContiguousCallStack, parameters.count > registers.count {
				assignments.argumentsRecordRegister = registers.popLast()
			}
			
			// As long as there is an argument register available, assign the next parameter to it.
			while let register = registers.popFirst(), let parameter = parameters.popFirst() {
				assignments.viaRegisters.append(.init(parameter: parameter, register: register))
			}
			
			// Assign remaining parameters to the arguments record.
			// If a contiguous call stack is in use, ensure stack order by reversing the fields.
			let parameterRecordFields = parameters
				.map { Lower.Field(.init(rawValue: $0.location.rawValue), $0.type.lowered()) }
			if configuration.callingConvention.usesContiguousCallStack {
				assignments.parameterRecordType = .init(parameterRecordFields.reversed())
			} else {
				assignments.parameterRecordType = .init(parameterRecordFields)
			}
			
			// Done.
			return assignments
			
		}
		
	}
	
}
