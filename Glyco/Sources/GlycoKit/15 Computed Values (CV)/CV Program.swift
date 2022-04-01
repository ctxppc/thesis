// Glyco © 2021–2022 Constantino Tsarouhas

//sourcery: longname = Computed Values
//sourcery: description = A language that allows a computation to be attached to a value.
public enum CV : Language {
	
	/// A program on a CV machine.
	public struct Program : Codable, GlycoKit.Program {
		
		public init(_ effect: Effect, procedures: [Procedure]) {
			self.effect = effect
			self.procedures = procedures
		}
		
		/// The program's effect.
		public var effect: Effect
		
		/// The program's procedures.
		public var procedures: [Procedure]
		
		// See protocol.
		public func optimise(configuration: CompilationConfiguration) -> Bool { false }
		
		// See protocol.
		public func validate(configuration: CompilationConfiguration) {}
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			try .init(effect.lowered(), procedures: procedures.lowered())
		}
		
	}
	
	// See protocol.
	public typealias Lower = CA
	
	typealias Context = ()
	
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias CapabilityType = Lower.CapabilityType
	public typealias Label = Lower.Label
	public typealias Location = Lower.Location
	public typealias Parameter = Lower.Parameter
	public typealias RecordType = Lower.RecordType
	public typealias Source = Lower.Source
	public typealias ValueType = Lower.ValueType
	
}
