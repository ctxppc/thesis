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
			
			let assignments = parameterAssignments(in: context.configuration)
			
			let parameterLocationPairs = chain(
				assignments.viaRegisters.map { ($0.parameter, Lower.Location.register($0.register)) },
				assignments.viaCallFrame.map { ($0.parameter, Lower.Location.frame($0.location)) }
			)
			
			let setArgumentLocations = parameterLocationPairs.map { parameter, location in
				Lower.Effect.set(parameter.type, .abstract(parameter.location), to: .location(location))
			}
			
			@EffectBuilder<Lower.Effect>
			var prologue: Lower.Effect {
				Lower.Effect.pushScope
				// TODO
			}
			
			return try .init(name, .do(
				[
					.push(.capability, .location(.register(.fp))),
					.set(.capability, .register(.fp), to: .location(.register(.sp))),
					
				] + setArgumentLocations + [
					effect.lowered(in: &context)
				]
			))
			
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
			while let parameter = parameters.popLast() {
				assignments.viaCallFrame.append(.init(parameter: parameter, location: frame.addParameter(parameter.type)))
			}
			assignments.viaCallFrame.reverse()	// ensure parameter order
			
			return assignments
			
		}
		
	}
	
}
