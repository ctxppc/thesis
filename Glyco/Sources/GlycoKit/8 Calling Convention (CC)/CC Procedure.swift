// Glyco © 2021–2022 Constantino Tsarouhas

import Algorithms

extension CC {
	
	/// A program element that can be invoked by name.
	public struct Procedure : Codable, Equatable, Named, SimplyLowerable {
		
		public init(_ name: Label, takes parameters: [Parameter], returns resultType: DataType, in effect: Effect) {
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
		public var resultType: DataType
		
		/// The procedure's effect when invoked.
		public var effect: Effect
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Procedure {
			.init(name, try .do {
				
				// Prepare new scope.
				Lower.Effect.pushScope
				
				// Copy callee-saved registers (except fp) to abstract locations to limit their liveness.
				for register in Lower.Register.defaultCalleeSavedRegisters {
					Lower.Effect.set(.capability, .abstract(context.calleeSaveLocation(for: register)), to: .location(.register(register)))
				}
				
				// Compute parameter assignments.
				let assignments = parameterAssignments(in: context.configuration)
				
				// Bind local names to register-resident arguments — limit liveness ranges by using the registers as early as possible.
				for assignment in assignments.viaRegisters {
					let parameter = assignment.parameter
					Lower.Effect.set(parameter.type, .abstract(parameter.location), to: .location(.register(assignment.register)))
				}
				
				// Bind local names to frame-resident arguments.
				for assignment in assignments.viaCallFrame {
					let parameter = assignment.parameter
					Lower.Effect.set(parameter.type, .abstract(parameter.location), to: .location(.frame(assignment.calleeLocation)))
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
			
			// As long as there is an argument register available, assign the next parameter to it.
			while let register = registers.popFirst(), let parameter = parameters.popFirst() {
				assignments.viaRegisters.append(.init(parameter: parameter, register: register))
			}
			
			// Assign remaining parameters to the call frame, in reverse order to ensure stack order — cf. `Frame.addParameter(_:count:)`.
			var frame = Lower.Frame()
			var callerOffset = 0
			while let parameter = parameters.popLast() {
				assignments.viaCallFrame.append(.init(
					parameter:		parameter,
					calleeLocation:	frame.addParameter(parameter.type),
					callerOffset:	callerOffset
				))
				callerOffset += parameter.type.byteSize
			}
			assignments.viaCallFrame.reverse()	// ensure parameter order
			
			return assignments
			
		}
		
	}
	
}
