// Glyco © 2021–2022 Constantino Tsarouhas

extension CC {
	public struct Parameter : Codable, Equatable {
		
		public init(_ location: Location, _ type: DataType) {
			self.location = location
			self.type = type
		}
		
		/// The location where the argument is stored and accessible from within the procedure.
		public let location: Location
		
		/// The data type of the argument.
		public let type: DataType
		
		/// An assignment of parameters to physical locations.
		struct Assignments {
			
			/// Assignments of parameters passed via registers.
			var viaRegisters: [RegisterAssignment] = []
			
			/// Assignments of parameters passed via the call frame.
			var viaCallFrame: [FrameAssignment] = []
			
		}
		
		/// An assignment of a parameter to a register.
		struct RegisterAssignment {
			
			/// The parameter being assigned to `register`.
			var parameter: Parameter
			
			/// The register that `parameter` is assigned to.
			///
			/// The caller stores the argument to and the callee loads the argument from this location.
			var register: Lower.Register
			
		}
		
		/// An assignment of a parameter to a call frame location.
		struct FrameAssignment {
			
			/// The parameter being assigned to `location`.
			var parameter: Parameter
			
			/// The frame location that `parameter` is assigned to relative to the callee's call frame.
			///
			/// The callee loads the argument from this location. The caller stores the argument to this location after computing the callee's frame capability.
			var location: Lower.Frame.Location
			
		}
		
	}
}
