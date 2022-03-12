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
				
				// Copy callee-saved registers (except fp) to abstract locations to limit their liveness.
				for register in Lower.Register.calleeSavedRegistersInCHERIRVABI {
					Lower.Effect.set(.abstract(context.calleeSaveLocation(for: register)), to: .register(register, .registerDatum))
				}
				
				// Determine parameter assignments.
				let assignments = parameterAssignments(in: context.configuration)
				
				// Bind local names to register-resident arguments — limit liveness ranges by using the registers as early as possible.
				for asn in assignments.viaRegisters {
					let parameter = asn.parameter
					Lower.Effect.set(.abstract(parameter.location), to: .register(asn.register, parameter.type))
				}
				
				// Bind local names to arguments in arguments record.
				// If arguments record capability is available, use it as a record; otherwise load from call frame.
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
					parameterRecordType.prependOrReplace(.init(name: "cc.__savedfp__", valueType: .vectorCap(.u8)))
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
			
			// Prepare available arguments registers and remaining parameters.
			var registers = configuration.argumentRegisters[...]
			var parameters = self.parameters[...]
			
			// If a discontiguous call stack is in use and an arguments record is required, reserve a register for the arguments record capability.
			if !configuration.callingConvention.usesContiguousCallStack, registers.count > parameters.count {
				assignments.argumentsRecordRegister = registers.popLast()
			}
			
			// As long as there is an argument register available, assign the next parameter to it.
			while let register = registers.popFirst(), let parameter = parameters.popFirst() {
				assignments.viaRegisters.append(.init(parameter: parameter, register: register))
			}
			
			// Assign remaining parameters to the arguments record.
			// If a contiguous call stack is in use, ensure stack order by reversing the fields.
			let parameterRecordFields = parameters
				.map { RecordType.Field(name: .init(rawValue: $0.location.rawValue), valueType: $0.type) }
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
