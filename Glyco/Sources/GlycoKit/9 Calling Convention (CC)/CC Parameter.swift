// Glyco © 2021–2022 Constantino Tsarouhas

extension CC {
	public struct Parameter : Codable, Equatable {
		
		public init(_ location: Location, _ type: ValueType) {
			self.location = location
			self.type = type
		}
		
		/// The location where the argument is stored and accessible from within the procedure.
		public let location: Location
		
		/// The data type of the argument.
		public let type: ValueType
		
		/// An assignment of parameters to physical locations.
		struct Assignments {
			
			/// Assignments of parameters passed via registers, in parameter order.
			var viaRegisters: [RegisterAssignment] = []
			
			/// Assignments of parameters passed via the call frame, in parameter order.
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
			
			/// The location in callee's frame that `parameter` is assigned to.
			///
			/// The callee loads the argument from this location.
			var calleeLocation: Lower.Frame.Location
			
			/// The offset in the caller's arguments structure that `parameter` is assigned to.
			///
			/// The caller stores the argument to this location.
			var callerOffset: Int
			
		}
		
	}
}

extension Sequence where Element == CC.Parameter {
	
	/// Returns the total size of the parameters in `self`, in bytes.
	func totalByteSize() -> Int {
		lazy.map(\.type.byteSize).reduce(0, +)
	}
	
}
