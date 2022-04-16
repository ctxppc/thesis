// Glyco © 2021–2022 Constantino Tsarouhas

extension CC {
	public struct Parameter : Codable, Equatable {
		
		/// Creates a parameter with given location and value type.
		public init(_ location: Location, _ type: ValueType, sealed: Bool) {
			self.location = location
			self.type = type
			self.sealed = sealed
		}
		
		/// The location where the argument is stored and accessible from within the procedure.
		public var location: Location
		
		/// The value type of the argument.
		///
		/// The type must be a sealed capability type if `sealed` is `true`. The argument is unsealed on the callee-side.
		public var type: ValueType
		
		/// A Boolean value indicating whether an argument to `self` is sealed, to be unsealed by the sealed call.
		///
		/// At most one parameter in a procedure can be marked as sealed.
		public var sealed: Bool
		
		/// An assignment of parameters to physical locations.
		struct Assignments {
			
			/// Creates an assignment for a procedure with given parameters and result type in given configuration.
			init(parameters: [Parameter], resultType: ValueType, configuration: CompilationConfiguration) {
				
				// Assign sealed parameter (if any) to invocation data register.
				var parameters = parameters[...]
				if let index = parameters.firstIndex(where: \.sealed) {
					viaRegisters.append(.init(parameter: parameters.remove(at: index), register: .invocationData))
				}
				
				// Prepare available arguments registers.
				var registers = configuration.argumentRegisters[...]
				
				// If a discontiguous call stack is in use and an arguments record is required, reserve a register for the arguments record capability.
				if !configuration.callingConvention.usesContiguousCallStack, parameters.count > registers.count {
					argumentsRecordRegister = registers.popLast()
				}
				
				// As long as there is an argument register available, assign the next parameter to it.
				while let register = registers.popFirst(), let parameter = parameters.popFirst() {
					viaRegisters.append(.init(parameter: parameter, register: register))
				}
				
				// Assign remaining parameters to the arguments record.
				// If a contiguous call stack is in use, ensure stack order by reversing the fields.
				let parameterRecordFields = parameters
					.map { Lower.Field(.init(rawValue: $0.location.rawValue), $0.type.lowered()) }
				if configuration.callingConvention.usesContiguousCallStack {
					parameterRecordType = .init(parameterRecordFields.reversed())
				} else {
					parameterRecordType = .init(parameterRecordFields)
				}
				
			}
			
			/// Assignments of parameters passed via registers, in parameter order.
			var viaRegisters: [RegisterAssignment] = []
			
			/// The record type for parameters passed via the call frame, with each field named after its corresponding parameter.
			///
			/// The fields in the record type are laid out in stack order, i.e., the first frame-resident argument is the last element (highest address) of the parameter record.
			var parameterRecordType = Lower.RecordType([])
			
			/// The register to which a capability to the arguments record is assigned, or `nil` if no such capability is passed to the callee.
			var argumentsRecordRegister: Lower.Register? = nil
			
		}
		
		/// An assignment of a parameter to a register.
		struct RegisterAssignment {
			
			/// The parameter being assigned to `register`.
			var parameter: Parameter
			
			/// The register that `parameter` is assigned to.
			///
			/// The caller puts the argument in and the callee retrieves the argument from this location. For sealed parameters, the caller-side assignment is done as part of the sealed call instead.
			var register: Lower.Register
			
		}
		
	}
}
