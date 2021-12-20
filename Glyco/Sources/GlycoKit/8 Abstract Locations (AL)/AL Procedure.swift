// Glyco © 2021 Constantino Tsarouhas

extension AL {
	
	/// A program element that can be invoked by name.
	public struct Procedure : Codable, Equatable, SimplyLowerable {
		
		/// The name with which the procedure can be invoked.
		public var name: Label
		
		/// The procedure's parameters.
		public var parameters: [Parameter]
		public enum Parameter : Codable, Equatable, SimplyLowerable {
			
			/// A parameter of given data type with argument accessible at given location.
			case parameter(Location, type: DataType)
			
			// See protocol.
			func lowered(in context: inout Context) -> Lower.Procedure.Parameter {
				switch self {
					case .parameter(_, type: let type):	return .parameter(type: type)
				}
			}
			
		}
		
		/// The procedure's effect when invoked.
		public var effect: Effect
		
		// See protocol.
		func lowered(in context: inout ()) throws -> Lower.Procedure {	// new AL.Context for each procedure
			let (_, conflicts) = effect.livenessAndConflictsAtEntry(livenessAtExit: .nothingUsed, conflictsAtExit: .conflictFree)
			var context = AL.Context(assignments: .init(parameters: parameters, conflicts: conflicts))
			return .init(
				name:		name,
				parameters:	try parameters.lowered(in: &context),
				effect:		try effect.lowered(in: &context)
			)
		}
		
	}
	
}
