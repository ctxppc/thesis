// Glyco © 2021–2022 Constantino Tsarouhas

extension PA {
	public struct Parameter : Codable, Equatable {
		
		public init(type: DataType) {
			self.type = type
		}
		
		/// The data type of the parameter.
		public var type: DataType
		
	}
}
