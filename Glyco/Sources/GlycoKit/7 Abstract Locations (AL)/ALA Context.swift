// Glyco © 2021–2022 Constantino Tsarouhas

extension ALA {
	
	/// A value used while lowering a program.
	struct GlobalContext {
		
		/// The compilation configuration.
		let configuration: CompilationConfiguration
		
	}
	
	/// A value used while lowering a procedure.
	struct LocalContext {
		
		/// The assignment of locations to physical locations.
		var assignments: ()	// TODO
		
	}
	
}
