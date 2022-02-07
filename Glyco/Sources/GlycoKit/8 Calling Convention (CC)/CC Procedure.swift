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
			
			let parameterLocationPairs = chain(
				assignments.viaRegisters.map { ($0.parameter, Lower.ParameterLocation.register($0.register)) },
				assignments.viaCallFrame.map { ($0.parameter, Lower.ParameterLocation.frame($0.calleeLocation)) }
			)
			
			let setArgumentLocations = parameterLocationPairs.map { parameter, location in
				Lower.Effect.set(parameter.type, .abstract(parameter.location), to: .location(.parameter(location)))
			}
			
			return try .init(name, .do(
				[
					.push(.capability, .location(.parameter(.register(.fp)))),
					.set(.capability, .parameter(.register(.fp)), to: .location(.parameter(.register(.sp)))),
					
				] + setArgumentLocations + [
					effect.lowered(in: &context)
				]
			))
			
		}
		
		/// Returns the assignments of the procedure's parameters to physical locations.
		func parameterAssignments(in configuration: CompilationConfiguration) -> Parameter.Assignments {
			
			var assignments = Parameter.Assignments()
			
			var frame = Lower.Frame()
			var registers = configuration.argumentRegisters[...]
			var parameters = self.parameters[...]
			
			while let register = registers.popFirst(), let parameter = parameters.popFirst() {
				assignments.viaRegisters.append(.init(parameter: parameter, register: register))
			}
			
			var calleeOffset = 0
			while let parameter = parameters.popFirst() {
				calleeOffset -= parameter.type.byteSize
				assignments.viaCallFrame.append(.init(
					parameter:		parameter,
					calleeLocation:	frame.allocate(parameter.type),
					callerOffset:	calleeOffset
				))
			}
			
			return assignments
			
		}
		
	}
	
}
