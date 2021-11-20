// Glyco © 2021 Constantino Tsarouhas

extension PA {
	
	/// A program element that can be invoked by name.
	public struct Procedure : Codable, Equatable, SimplyLowerable {
		
		/// Creates a procedure with given name, body, and parameters.
		public init(name: Label, body: Statement, parameters: [Parameter]) {
			self.name = name
			self.body = body
			self.parameters = parameters
		}
		
		/// The name with which the procedure can be invoked.
		public var name: Label
		
		/// The procedure's body.
		public var body: Statement
		
		/// The procedure's parameters.
		public var parameters: [Parameter]
		public struct Parameter : Codable, Equatable {
			
			/// The data type of the parameter.
			public let dataType: DataType
			
			/// The abstract location which can be used in the procedure's body to refer to the parameter's argument.
			///
			/// The location must not be assigned to more than one parameter.
			public let argumentLocation: Location
			
			/// An assignment of a parameter to a physical location.
			struct Assignment {
				
				/// Assigns `parameter` to the first available register in `availableRegisters`, or to the first available location in `frame` if no registers are available.
				init(parameter: Parameter, availableRegisters: inout ArraySlice<Lower.ParameterRegister>, frame: inout Lower.Frame) {
					self.parameter = parameter
					if let (assignableRegister, remainingRegisters) = availableRegisters.splittingFirst() {
						availableRegisters = remainingRegisters
						physicalLocation = .parameterRegister(assignableRegister)
					} else {
						physicalLocation = .frameLocation(frame.allocate(parameter.dataType))
					}
				}
				
				/// The parameter being assigned.
				let parameter: Parameter
				
				/// The physical location of the parameter.
				let physicalLocation: Lower.Location
				
			}
			
		}
		
		/// Returns assignments for the procedure's parameters, in the same order as the parameters.
		func parameterAssignments() -> [Parameter.Assignment] {
			var availableRegisters = Lower.ParameterRegister.allCases[...]
			var frame = Lower.Frame()
			return parameters.map { parameter in
				.init(parameter: parameter, availableRegisters: &availableRegisters, frame: &frame)
			}
		}
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Procedure {
			let prologueStatements: [Lower.Statement] = parameterAssignments().map {
				$0.parameter.argumentLocation <- .location(location: $0.physicalLocation)
			}	// assign register parameters first to keep those register's liveness as short as possible
			return .init(name: name, body: .compound(statements: prologueStatements + [try body.lowered(in: &context)]))
		}
		
	}
	
}
