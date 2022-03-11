// Glyco © 2021–2022 Constantino Tsarouhas

//sourcery: longname = Predicates
//sourcery: description = A language that introduces predicates in branches.
public enum PR : Language {
	
	/// A program on a PR machine.
	public struct Program : Codable, GlycoKit.Program {
		
		public init(_ blocks: [Block]) {
			self.blocks = blocks
		}
		
		/// The program's blocks.
		///
		/// Exactly one block must be labelled with `.programEntry`.
		public var blocks: [Block]
		
		// See protocol.
		public func optimise() -> Bool { false }
		
		// See protocol.
		public func validate() {}
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			.init(try blocks.lowered())
		}
		
	}
	
	// See protocol.
	public typealias Lower = BB
	
	public typealias Context = ()
	
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias DataType = Lower.DataType
	public typealias Effect = Lower.Effect
	public typealias Frame = Lower.Frame
	public typealias Label = Lower.Label
	public typealias Location = Lower.Location
	public typealias Register = Lower.Register
	public typealias RuntimeRoutine = Lower.RuntimeRoutine
	public typealias Source = Lower.Source
	
}
