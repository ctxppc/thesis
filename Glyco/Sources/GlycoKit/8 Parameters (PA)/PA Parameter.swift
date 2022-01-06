// Glyco © 2021–2022 Constantino Tsarouhas

extension PA {
	public struct Parameter : Codable, Equatable, SimplyLowerable {
		
		public init(_ location: Location, _ type: DataType) {
			self.location = location
			self.type = type
		}
		
		/// The location where the argument is stored and accessible from within the procedure.
		public let location: Location
		
		/// The data type of the argument.
		public let type: DataType
		
		// See protocol.
		func lowered(in context: inout ()) -> Lower.Parameter {
			.init(location, type)
		}
		
		/// An assignment of parameters to physical locations.
		struct Assignments {
			var registers: [Lower.Register] = []
			var frameLocations: [Lower.Frame.Location] = []
		}
		
	}
}