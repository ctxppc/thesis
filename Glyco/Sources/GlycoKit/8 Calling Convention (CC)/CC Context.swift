// Glyco © 2021–2022 Constantino Tsarouhas

extension CC {
	
	/// A value used while lowering a procedure.
	struct Context {
		
		init(procedures: [Procedure], configuration: CompilationConfiguration) {
			self.procedures = procedures
			self.configuration = configuration
		}
		
		/// The program's procedures.
		let procedures: [Procedure]
		
		/// The procedure being lowered, or `nil` if no procedure is being lowered.
		var loweredProcedure: Procedure? = nil
		
		/// The compilation configuration.
		let configuration: CompilationConfiguration
		
		/// The locations bag.
		var locations = Bag<Location>()
		
		/// Returns the location for given callee-saved register.
		mutating func calleeSaveLocation(for register: Lower.Register) -> Location {
			if let location = calleeSaveLocationByRegister[register] {
				return location
			} else {
				let location = locations.uniqueName(from: "saved\(register.rawValue.uppercased())")
				calleeSaveLocationByRegister[register] = location
				return location
			}
		}
		
		/// The locations by callee-saved register.
		private var calleeSaveLocationByRegister = [Lower.Register : Location]()
		
	}
	
}
