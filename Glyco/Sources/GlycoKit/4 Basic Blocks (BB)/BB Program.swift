// Glyco © 2021–2022 Constantino Tsarouhas

//sourcery: longname = Basic Blocks
//sourcery: description = A language that groups effects into blocks of effects where blocks can only be entered at a single entry point and exited at a single exit point.
public enum BB : Language {
	
	/// A program on an BB machine.
	public struct Program : Codable, GlycoKit.Program {
		
		/// Creates a program with given blocks
		public init(_ blocks: [BB.Block]) {
			self.blocks = blocks
		}
		
		/// The program's blocks.
		///
		/// Exactly one block must be labelled with `.entry`.
		public var blocks: [Block]
		
		// See protocol.
		public func optimise() -> Bool { false }
		
		// See protocol.
		public func validate() {}
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			.init(try blocks.lowered())	// TODO: Implement optimal trace.
		}
		
	}
	
	// See protocol.
	public typealias Lower = FO
	
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias DataType = Lower.DataType
	public typealias Frame = Lower.Frame
	public typealias Label = Lower.Label
	public typealias Location = Lower.Location
	public typealias Register = Lower.Register
	public typealias Source = Lower.Source
	
}
