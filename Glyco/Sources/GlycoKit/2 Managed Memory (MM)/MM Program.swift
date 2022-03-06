// Glyco © 2021–2022 Constantino Tsarouhas

//sourcery: longname = Managed Memory
//sourcery: description = "A language that introduces the call stack, the heap, and operations on them."
public enum MM : Language {
	
	/// An MM program.
	public struct Program : Codable, GlycoKit.Program {
		
		/// Creates a program with given effects.
		public init(_ effects: [Effect] = []) {
			self.effects = effects
		}
		
		/// The program's effects.
		public var effects: [Effect] = []
		
		// See protocol.
		public func optimise() -> Bool { false }
		
		// See protocol.
		public func validate() {}
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			
			let allocLabel = "mm.alloc" as Label
			let allocEndLabel = "mm.alloc.end" as Label
			let allocCapLabel = "mm.alloc.cap" as Label
			
			let heapLabel = "mm.heap" as Label
			let heapEndLabel = "mm.heap.end" as Label
			let heapCapLabel = "mm.heap.cap" as Label
			
			let userLabel = "mm.user" as Label
			let userEndLabel = "mm.user.end" as Label
			
			// Routines are allowed to touch all argument registers.
			let actualLengthReg = Lower.Register.a3
			let permissionsMaskReg = Lower.Register.a4
			
			// A routine that initialises the runtime. It does not take arguments or return a value.
			@StatementsBuilder
			var initialisationRoutine: [Lower.Statement] {
				
				Lower.Statement.padding(byteAlignment: 4)
				
				do {
					
					let heapCapReg = Lower.Register.a0
					let heapCapEndReg = Lower.Register.a1
					let heapCapLengthReg = Lower.Register.a2
					let heapCapCapReg = Lower.Register.a3
					
					// Derive heap cap.
					Lower.Statement.labelled(.initialise, .instruction(.deriveCapabilityFromLabel(destination: heapCapReg, label: heapLabel)))
					
					// Restrict heap cap bounds.
					Lower.Instruction.deriveCapabilityFromLabel(destination: heapCapEndReg, label: heapEndLabel)
					Lower.Instruction.getCapabilityDistance(destination: heapCapLengthReg, cs1: heapCapEndReg, cs2: heapCapReg)
					Lower.Instruction.setCapabilityBounds(destination: heapCapReg, source: heapCapReg, length: heapCapLengthReg)
					
					// Restrict heap cap permissions.
					Lower.Instruction.computeWithImmediate(
						operation:	.add,
						rd:			permissionsMaskReg,
						rs1:		.zero,
						imm:		.init(Self.heapCapabilityPermissions.bitmask)
					)
					Lower.Instruction.permit(destination: heapCapReg, source: heapCapReg, mask: permissionsMaskReg)
					
					// Derive heap cap cap and store heap cap.
					Lower.Instruction.deriveCapabilityFromLabel(destination: heapCapCapReg, label: heapCapLabel)
					Lower.Instruction.storeCapability(source: heapCapReg, address: heapCapCapReg)
					
				}
				
				do {
					
					let allocCapReg = Lower.Register.a0
					let allocCapEndReg = Lower.Register.a1
					let allocCapLengthReg = Lower.Register.a2
					let allocCapCapReg = Lower.Register.a3
					
					// Derive alloc cap.
					Lower.Instruction.deriveCapabilityFromLabel(destination: allocCapReg, label: allocLabel)
					
					// Restrict alloc cap bounds.
					Lower.Instruction.deriveCapabilityFromLabel(destination: allocCapEndReg, label: allocEndLabel)
					Lower.Instruction.getCapabilityDistance(destination: allocCapLengthReg, cs1: allocCapEndReg, cs2: allocCapReg)
					Lower.Instruction.setCapabilityBounds(destination: allocCapReg, source: allocCapReg, length: allocCapLengthReg)
					
					// Restrict alloc cap permissions.
					Lower.Instruction.computeWithImmediate(
						operation:	.add,
						rd:			permissionsMaskReg,
						rs1:		.zero,
						imm:		.init(Self.allocCapabilityPermissions.bitmask)
					)
					Lower.Instruction.permit(destination: allocCapReg, source: allocCapReg, mask: permissionsMaskReg)
					Lower.Instruction.sealEntry(destination: allocCapReg, source: allocCapReg)
					
					// Derive alloc cap cap and store alloc cap.
					Lower.Instruction.deriveCapabilityFromLabel(destination: allocCapCapReg, label: allocCapLabel)
					Lower.Instruction.storeCapability(source: allocCapReg, address: allocCapCapReg)
					
				}
				
				// Return to caller.
				Lower.Instruction.return
				
			}
			
			// A routine that allocates a buffer on the heap. It takes a length in a0 and returns a buffer cap in ca0.
			@StatementsBuilder
			var allocationRoutine: [Lower.Statement] {
				
				let heapCapCapReg = Lower.Register.a1
				let heapCapReg = Lower.Register.a2
				
				Lower.Statement.padding(byteAlignment: 4)
				
				// Derive heap cap cap and load heap cap.
				Lower.Statement.labelled(allocLabel, .instruction(.deriveCapabilityFromLabel(destination: heapCapCapReg, label: heapCapLabel)))
				Lower.Instruction.loadCapability(destination: heapCapReg, address: heapCapCapReg)
				
				// Derive buffer cap into ca0 using length in a0.
				Lower.Instruction.setCapabilityBounds(destination: .a0, source: heapCapReg, length: .a0)
				
				// Determine (possibly rounded-up) length of allocated buffer.
				Lower.Instruction.getCapabilityLength(destination: actualLengthReg, source: .a0)
				
				// Move heap capability over the allocated region.
				Lower.Instruction.offsetCapability(destination: heapCapReg, source: heapCapReg, offset: actualLengthReg)
				
				// Store updated heap cap using heap cap cap.
				Lower.Instruction.storeCapability(source: heapCapReg, address: heapCapCapReg)
				
				// Return to caller.
				Lower.Instruction.return
				
				// Heap capability.
				Lower.Statement.labelled(heapCapLabel, .nullCapability)
				
				// End of routine.
				Lower.Statement.labelled(allocEndLabel, .signedWord(0))
				
			}
			
			@StatementsBuilder
			var user: [Lower.Statement] {
				get throws {
					
					// Alloc capability.
					Lower.Statement.labelled(
						userLabel, .labelled(allocCapLabel, .nullCapability)
					)
					
					// User code.
					Lower.Statement.padding(byteAlignment: 4)
					try effects.lowered()
					
					Lower.Statement.labelled(userEndLabel, .signedWord(0))
					
				}
			}
			
			@StatementsBuilder
			var heap: [Lower.Statement] {
				Lower.Statement.labelled(heapLabel, .filled(value: 0, datumByteSize: 1, copies: configuration.heapByteSize))
				Lower.Statement.labelled(heapEndLabel, .signedWord(0))
			}	// FIXME: Zeroed heap is emitted in ELF; define a (lazily zeroed) section instead?
			
			return try .init {
				initialisationRoutine
				allocationRoutine
				try user
				heap
			}
			
		}
		
		/// The heap capability's permissions.
		///
		/// Buffer capabilities derive their permissions directly from the heap capability; the runtime does not impose further restrictions.
		static let heapCapabilityPermissions = [Permission.load, .loadCapability, .store, .storeCapability]
		
		/// The allocation routine capability's permissions.
		///
		/// The capability is used for executing the routine as well as to load & store (update) the heap capability which is stored inside the routine's memory region.
		static let allocCapabilityPermissions = [Permission.execute, .loadCapability, .storeCapability]
		
	}
	
	// See protocol.
	public typealias Lower = RV
	
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias Label = Lower.Label
	
}
