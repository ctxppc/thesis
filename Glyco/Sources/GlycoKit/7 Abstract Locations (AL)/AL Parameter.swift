// Glyco © 2021–2022 Constantino Tsarouhas

extension AL {
	public struct Parameter : Codable, Equatable {
		
		public init(_ location: AbstractLocation, _ type: DataType) {
			self.location = location
			self.type = type
		}
		
		/// The location where the argument is stored and accessible from within the procedure.
		public let location: AbstractLocation
		
		/// The data type of the argument.
		public let type: DataType
		
	}
}
