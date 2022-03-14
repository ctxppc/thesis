// Glyco © 2021–2022 Constantino Tsarouhas

extension ALA {
	
	/// A value used while lowering a procedure.
	struct Context {
		
		/// The declarations.
		let declarations: Declarations
		
		/// The assignment of locations to physical locations.
		var assignments: Location.Assignments
		
		/// The compilation configuration.
		let configuration: CompilationConfiguration
		
	}
	
}
