// Glyco © 2021–2022 Constantino Tsarouhas

extension PA {
	
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
		public struct Parameter : Codable, Equatable {
			
			public init(type: DataType) {
				self.type = type
			}
			
			/// The data type of the parameter.
			public var type: DataType
			
		}
		
		/// The procedure's effect when invoked.
		var effect: Effect
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Procedure {
			.init(name: name, effect: try effect.lowered(in: &context))
		}
		
		// See protocol.
		public enum CodingKeys : String, CodingKey {
			case name = "_0"
			case parameters = "_1"
			case effect = "_2"
		}
		
	}
	
}
