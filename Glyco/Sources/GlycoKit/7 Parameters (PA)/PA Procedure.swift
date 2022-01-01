// Glyco © 2021–2022 Constantino Tsarouhas

extension PA {
	
	/// A program element that can be invoked by name.
	public struct Procedure : Codable, Equatable, SimplyLowerable {
		
		/// The name with which the procedure can be invoked.
		var name: Label
		
		/// The procedure's parameters.
		var parameters: [Parameter]
		public enum Parameter : Codable, Equatable {
			
			/// A parameter of given data type.
			case parameter(type: DataType)
			
			/// The data type of the parameter.
			public var type: DataType {
				switch self {
					case .parameter(type: let type):	return type
				}
			}
			
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
