// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation
import OrderedCollections

//sourcery: longname = Basic Blocks
//sourcery: description = A language that groups effects into blocks of effects where blocks can only be entered at a single entry point and exited at a single exit point.
public enum BB : Language {
	
	/// A program on an BB machine.
	public struct Program : GlycoKit.Program {
		
		/// Creates a program with given blocks
		public init(_ blocks: [BB.Block]) {
			self.blocks = blocks
		}
		
		/// The program's blocks.
		///
		/// Exactly one block must be labelled with `.programEntry`.
		public var blocks: [Block]
		
		// See protocol.
		public mutating func optimise(configuration: CompilationConfiguration) throws -> Bool {
			
			var optimised = false
			
			// Substitute each empty block with a continue continuation with the block's successor.
			for removedBlockIndex in blocks.indices.reversed() {
				let removedBlock = blocks[removedBlockIndex]
				guard removedBlock.effects.isEmpty else { continue }
				guard removedBlock.name != .programEntry else { continue }
				guard case .continue(let newSuccessor) = removedBlock.continuation else { continue }
				blocks.remove(at: removedBlockIndex)
				for index in blocks.indices {
					blocks[index].continuation.substitute(removedBlock.name, by: newSuccessor)
				}
				optimised = true
			}
			
			return optimised
			
		}
		
		// See protocol.
		public func validate(configuration: CompilationConfiguration) {}
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			
			var remainingBlocksByName = try OrderedDictionary<Block.Name, Block>(	// ordered dictionary to preserve ordering of procedures
				blocks.lazy.map { ($0.name, $0) },
				uniquingKeysWith: { block, _ in throw LoweringError.duplicateBlockName(block.name) }
			)
			
			var loweredProgramEffects = [Lower.Effect]()
			func appendBlockOrJumpToBlock(named loweredBlockName: Block.Name) throws {
				if let block = remainingBlocksByName.removeValue(forKey: loweredBlockName) {
					
					if let (head, tail) = try block.effects.lowered().splittingFirst() {
						loweredProgramEffects.append(.labelled(loweredBlockName, head))
						loweredProgramEffects.append(contentsOf: tail)
					} else {
						loweredProgramEffects.append(.labelled(loweredBlockName, .nop))
					}
					
					switch block.continuation {
						
						case .continue(to: let successor):
						try appendBlockOrJumpToBlock(named: successor)
						
						case .branch(let lhs, let relation, let rhs, then: let affirmative, else: let negative):
						loweredProgramEffects.append(.branch(to: affirmative, lhs, relation, rhs))
						try appendBlockOrJumpToBlock(named: negative)
						try appendBlockOrJumpToBlock(named: affirmative)
						
						case .call(let target, returnPoint: let returnPoint):
						loweredProgramEffects.append(.call(target))
						try appendBlockOrJumpToBlock(named: returnPoint)
						
						case .callSealed(let target, data: let data, returnPoint: let returnPoint):
						loweredProgramEffects.append(.callSealed(target, data: data, returnPoint: returnPoint))
						try appendBlockOrJumpToBlock(named: returnPoint)
						
						case .return(to: let caller):
						loweredProgramEffects.append(.return(to: caller))
						
					}
					
				} else {
					loweredProgramEffects.append(.jump(to: loweredBlockName))
				}
			}
			
			try appendBlockOrJumpToBlock(named: .programEntry)	// first block must be program entry
			while let blockName = remainingBlocksByName.keys.first {
				try appendBlockOrJumpToBlock(named: blockName)
			}
			
			return .init(loweredProgramEffects)
			
		}
		
		enum LoweringError : LocalizedError {
			
			/// An error indicating that multiple blocks have the same name.
			case duplicateBlockName(Block.Name)
			
			// See protocol.
			var errorDescription: String? {
				switch self {
					case .duplicateBlockName(let name):
					return "Multiple blocks named “\(name)”"
				}
			}
			
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
