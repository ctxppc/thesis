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
		
		/// Returns the location for given saved register.
		mutating func saveLocation(for register: Lower.Register) -> Location {
			if let location = saveLocationByRegister[register] {
				return location
			} else {
				let location = locations.uniqueName(from: "saved\(register.rawValue.uppercased())")
				saveLocationByRegister[register] = location
				return location
			}
		}
		
		/// The locations by saved register.
		private var saveLocationByRegister = [Lower.Register : Location]()
		
	}
	
}
