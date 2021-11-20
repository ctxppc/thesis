// Glyco © 2021 Constantino Tsarouhas

extension PA {
	
	/// A program element that can be invoked by name.
	public struct Procedure : Codable, Equatable, SimplyLowerable {
		
		/// The name with which the procedure can be invoked.
		var name: Label
		
		/// The procedure's effect when invoked.
		var effect: Effect
		
		/// The procedure's parameters.
		var parameters: [Parameter]
		public struct Parameter : Codable, Equatable {
			
			/// The data type of the parameter.
			public let dataType: DataType
			
		}
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Procedure {
			.init(name: name, effect: try effect.lowered(in: &context))
		}
		
	}
	
}
