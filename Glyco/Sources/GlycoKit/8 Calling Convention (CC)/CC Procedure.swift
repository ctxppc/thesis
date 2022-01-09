// Glyco © 2021–2022 Constantino Tsarouhas

import Algorithms

extension CC {
	
	/// A program element that can be invoked by name.
	public struct Procedure : Codable, Equatable, SimplyLowerable {
		
		public init(_ name: Label, _ parameters: [Parameter], _ effect: Effect) {
			self.name = name
			self.parameters = parameters
			self.effect = effect
		}
		
		/// The name with which the procedure can be invoked.
		public var name: Label
		
		/// The procedure's parameters.
		public var parameters: [Parameter]
		
		/// The procedure's effect when invoked.
		public var effect: Effect
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Procedure {
			
			let assignments = parameterAssignments(in: context.configuration)
			let parameterLocations = chain(
				assignments.registers.map { Lower.ParameterLocation.register($0) },
				assignments.frameLocations.map { .frame($0) }
			)
			
			let prologue = zip(parameters, parameterLocations).map { parameter, location in
				Lower.Effect.set(.abstract(parameter.location), to: .location(.parameter(location)))
			}
			
			return try .init(name, .do(prologue + [effect.lowered(in: &context)]))
			
		}
		
		/// Returns the assignments of the procedure's parameters to physical locations.
		func parameterAssignments(in configuration: CompilationConfiguration) -> Parameter.Assignments {
			
			var assignments = Parameter.Assignments()
			
			var frame = Lower.Frame()
			var registers = configuration.argumentRegisters[...]
			
			var parameters = self.parameters[...]
			while let register = registers.popFirst(), let _ = parameters.popFirst() {
				assignments.registers.append(register)
			}
			while let parameter = parameters.popFirst() {
				assignments.frameLocations.append(frame.allocate(parameter.type))
			}
			
			return assignments
			
		}
		
	}
	
}
