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
		
		/// The abstract locations bag.
		var locations = Bag<Lower.AbstractLocation>()
		
		/// Returns the location for given saved register.
		mutating func saveLocation(for register: Lower.Register) -> Lower.AbstractLocation {
			if let location = saveLocationByRegister[register] {
				return location
			} else {
				let location = locations.uniqueName(from: "saved\(register.rawValue.uppercased())")
				saveLocationByRegister[register] = location
				return location
			}
		}
		
		/// The locations by saved register.
		private var saveLocationByRegister = [Lower.Register : Lower.AbstractLocation]()
		
		/// The location of the return capability.
		private(set) lazy var returnLocation = locations.uniqueName(from: "retcap")
		
	}
	
}
