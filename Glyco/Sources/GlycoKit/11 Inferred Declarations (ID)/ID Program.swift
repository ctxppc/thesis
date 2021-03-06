// Glyco © 2021–2022 Constantino Tsarouhas

import Sisp

//sourcery: longname = Inferred Declarations
//sourcery: description = "A language that infers declarations from definitions."
public enum ID : Language {
	
	/// A program on an ID machine.
	public struct Program : GlycoKit.Program {
		
		public init(_ effect: Effect, procedures: [Procedure]) {
			self.effect = effect
			self.procedures = procedures
		}
		
		/// The program's effect.
		public var effect: Effect
		
		/// The program's procedures.
		@Defaulted<Empty>
		public var procedures: [Procedure]
		
		// See protocol.
		public func optimise(configuration: CompilationConfiguration) -> Bool { false }
		
		// See protocol.
		public func validate(configuration: CompilationConfiguration) {}
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			var context = Context()
			let effect = try effect.lowered(in: &context)	// first get declarations into context
			return try .init(locals: context.declarations, in: effect, procedures: procedures.lowered())
		}
		
	}
	
	// See protocol.
	public typealias Lower = AL
	
	public typealias AbstractLocation = Lower.AbstractLocation
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias DataType = Lower.DataType
	public typealias Declarations = Lower.Declarations
	public typealias Frame = Lower.Frame
	public typealias Label = Lower.Label
	public typealias Location = Lower.Location
	public typealias Register = Lower.Register
	public typealias Source = Lower.Source
	
}
