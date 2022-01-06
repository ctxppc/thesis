// Glyco © 2021–2022 Constantino Tsarouhas

extension PA {
	
	/// A value used while lowering a procedure.
	struct Context {
		
		/// The program's procedures.
		let procedures: [Procedure]
		
		/// The compilation configuration.
		let configuration: CompilationConfiguration
		
	}
	
}
