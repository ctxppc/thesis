// Glyco © 2021–2022 Constantino Tsarouhas

extension CC {
	public struct Parameter : Codable, Equatable {
		
		/// Creates a parameter with given location and value type.
		public init(_ location: Location, _ type: ValueType) {
			self.location = location
			self.type = type
		}
		
		/// The location where the argument is stored and accessible from within the procedure.
		public let location: Location
		
		/// The value type of the argument.
		public let type: ValueType
		
		/// An assignment of parameters to physical locations.
		struct Assignments {
			
			/// Assignments of parameters passed via registers, in parameter order.
			var viaRegisters: [RegisterAssignment] = []
			
			/// The record type for parameters passed via the call frame, with each field named after its corresponding parameter.
			///
			/// The fields in the record type are laid out in stack order, i.e., the first frame-resident argument is the last element (highest address) of the parameter record.
			var parameterRecordType = RecordType([])
			
			/// The register to which a capability to the arguments record is assigned, or `nil` if no such capability is passed to the callee.
			var argumentsRecordRegister: Lower.Register? = nil
			
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
		
	}
}

extension Sequence where Element == CC.Parameter {
	
	/// Returns the total size of the parameters in `self`, in bytes.
	func totalByteSize() -> Int {
		lazy.map(\.type.byteSize).reduce(0, +)
	}
	
}
