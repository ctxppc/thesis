// Glyco © 2021 Constantino Tsarouhas

/// A language that introduces procedure parameters using the PA calling convention.
public enum PA : Language {
	
	/// A program on a PA machine.
	public struct Program : Codable, GlycoKit.Program {
		
		/// The program's effect.
		public var effect: Effect
		
		/// The program's procedures.
		public var procedures: [Procedure]
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			var context = Context(procedures: procedures)
			return try .init(effect: effect.lowered(in: &context), procedures: procedures.lowered(in: &context))
		}
		
	}
	
	// See protocol.
	public typealias Lower = CD
	
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias DataType = Lower.DataType
	public typealias Frame = Lower.Frame
	public typealias Label = Lower.Label
	public typealias Location = Lower.Location
	public typealias Predicate = Lower.Predicate
	public typealias Register = Lower.Register
	public typealias Source = Lower.Source
	
}