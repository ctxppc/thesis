// Glyco © 2021–2022 Constantino Tsarouhas

/// A language that introduces predicates in branches.
public enum PR : Language {
	
	/// A program on a PR machine.
	public struct Program : Codable, GlycoKit.Program {
		
		/// The program's blocks.
		///
		/// Exactly one block must be labelled with `.programEntry`.
		public var blocks: [Block]
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			.init(blocks: try blocks.lowered())
		}
		
		// See protocol.
		public enum CodingKeys : String, CodingKey {
			case blocks = "_0"
		}
		
	}
	
	// See protocol.
	public typealias Lower = BB
	
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias DataType = Lower.DataType
	public typealias Effect = Lower.Effect
	public typealias Frame = Lower.Frame
	public typealias Label = Lower.Label
	public typealias Location = Lower.Location
	public typealias Register = Lower.Register
	public typealias Source = Lower.Source
	
}
