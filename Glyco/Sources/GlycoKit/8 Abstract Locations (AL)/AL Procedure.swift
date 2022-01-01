// Glyco © 2021–2022 Constantino Tsarouhas

extension AL {
	
	/// A program element that can be invoked by name.
	public struct Procedure : Codable, Equatable, SimplyLowerable {
		
		/// The name with which the procedure can be invoked.
		public var name: Label
		
		/// The procedure's parameters.
		public var parameters: [Parameter]
		public struct Parameter : Codable, Equatable, SimplyLowerable {
			
			/// The location where the argument is stored and accessible from within the procedure.
			let location: Location
			
			/// The data type of the argument.
			let type: DataType
			
			// See protocol.
			func lowered(in context: inout LocalContext) -> Lower.Procedure.Parameter {
				.parameter(type: type)
			}
			
			// See protocol.
			public enum CodingKeys : String, CodingKey {
				case location = "_0"
				case type = "_1"
			}
			
		}
		
		/// The procedure's effect when invoked.
		public var effect: Effect
		
		// See protocol.
		func lowered(in context: inout GlobalContext) throws -> Lower.Procedure {
			let (_, conflicts) = effect.livenessAndConflictsAtEntry(livenessAtExit: .nothingUsed, conflictsAtExit: .conflictFree)
			var context = AL.LocalContext(
				assignments: .init(
					parameters:			parameters,
					conflicts:			conflicts,
					argumentRegisters:	context.configuration.argumentRegisters
				)
			)
			return .init(
				name:		name,
				parameters:	try parameters.lowered(in: &context),
				effect:		try effect.lowered(in: &context)
			)
		}
		
		// See protocol.
		public enum CodingKeys : String, CodingKey {
			case name = "_0"
			case parameters = "_1"
			case effect = "_2"
		}
		
	}
	
}
