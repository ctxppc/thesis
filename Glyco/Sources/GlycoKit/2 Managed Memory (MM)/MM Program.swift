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
			
			var context = Context(configuration: configuration)
			
			let allocLabel = "mm.alloc" as Label
			let allocEndLabel = "mm.alloc.end" as Label
			let allocCapLabel = Label.allocationRoutineCapability
			
			let heapLabel = "mm.heap" as Label
			let heapEndLabel = "mm.heap.end" as Label
			let heapCapLabel = "mm.heap.cap" as Label
			
			let userLabel = "mm.user" as Label
			let userEndLabel = "mm.user.end" as Label
			
			// Implementation note: the following code is structured as to facilitate manual register allocation. #ohno
			
			// A routine that initialises the runtime and restricts the user's authority. It touches all registers.
			@StatementsBuilder
			var initialisationRoutine: [Lower.Statement] {
				
				// Initialise heap cap.
				do {
					
					// Derive heap cap.
					let heapCapReg = Lower.Register.t0
					(.initialise) ~ .deriveCapabilityFromLabel(destination: heapCapReg, label: heapLabel)
					
					// Restrict heap cap bounds.
					let heapCapEndReg = Lower.Register.t1
					let heapCapLengthReg = Lower.Register.t1
					Lower.Instruction.deriveCapabilityFromLabel(destination: heapCapEndReg, label: heapEndLabel)
					Lower.Instruction.getCapabilityDistance(destination: heapCapLengthReg, cs1: heapCapEndReg, cs2: heapCapReg)
					Lower.Instruction.setCapabilityBounds(destination: heapCapReg, source: heapCapReg, length: heapCapLengthReg)
					
					// Restrict heap cap permissions.
					let permissionsReg = Lower.Register.t1
					let bitmask = Self.heapCapabilityPermissions.bitmask
					Lower.Instruction.computeWithImmediate(operation: .add, rd: permissionsReg, rs1: .zero, imm: .init(bitmask))
					Lower.Instruction.permit(destination: heapCapReg, source: heapCapReg, mask: permissionsReg)
					
					// Derive heap cap cap and store heap cap.
					let heapCapCapReg = Lower.Register.t1
					Lower.Instruction.deriveCapabilityFromLabel(destination: heapCapCapReg, label: heapCapLabel)
					Lower.Instruction.storeCapability(source: heapCapReg, address: heapCapCapReg)
					
				}
				
				// Initialise alloc cap.
				do {
					
					// Derive alloc cap.
					let allocCapReg = Lower.Register.t0
					Lower.Instruction.deriveCapabilityFromLabel(destination: allocCapReg, label: allocLabel)
					
					// Restrict alloc cap bounds.
					let allocCapEndReg = Lower.Register.t1
					let allocCapLengthReg = Lower.Register.t1
					Lower.Instruction.deriveCapabilityFromLabel(destination: allocCapEndReg, label: allocEndLabel)
					Lower.Instruction.getCapabilityDistance(destination: allocCapLengthReg, cs1: allocCapEndReg, cs2: allocCapReg)
					Lower.Instruction.setCapabilityBounds(destination: allocCapReg, source: allocCapReg, length: allocCapLengthReg)
					
					// Restrict alloc cap permissions.
					let permissionsReg = Lower.Register.t1
					let bitmask = Self.allocCapabilityPermissions.bitmask
					Lower.Instruction.computeWithImmediate(operation: .add, rd: permissionsReg, rs1: .zero, imm: .init(bitmask))
					Lower.Instruction.permit(destination: allocCapReg, source: allocCapReg, mask: permissionsReg)
					Lower.Instruction.sealEntry(destination: allocCapReg, source: allocCapReg)
					
					// Derive alloc cap cap and store alloc cap.
					let allocCapCapReg = Lower.Register.t1
					Lower.Instruction.deriveCapabilityFromLabel(destination: allocCapCapReg, label: allocCapLabel)
					Lower.Instruction.storeCapability(source: allocCapReg, address: allocCapCapReg)
					
				}
				
				// TODO: Clear all registers except (selected) user authority.
				
				// Return to caller.
				Lower.Instruction.return
				
			}
			
			// A routine that allocates a buffer on the heap. It takes a length in t0 and returns a buffer cap in ct0. It also touches t1 and t2.
			@StatementsBuilder
			var allocationRoutine: [Lower.Statement] {
				
				let lengthReg = Lower.Register.t0	// input
				let bufferReg = Lower.Register.t0	// output (same location as input)
				
				// Derive heap cap cap and load heap cap.
				let heapCapCapReg1 = Lower.Register.t1
				let heapCapReg = Lower.Register.t1
				allocLabel ~ .deriveCapabilityFromLabel(destination: heapCapCapReg1, label: heapCapLabel)
				Lower.Instruction.loadCapability(destination: heapCapReg, address: heapCapCapReg1)
				
				// Derive buffer cap into ca0 using length in a0.
				Lower.Instruction.setCapabilityBounds(destination: bufferReg, source: heapCapReg, length: lengthReg)
				
				// Determine (possibly rounded-up) length of allocated buffer.
				let actualLengthReg = Lower.Register.t2
				Lower.Instruction.getCapabilityLength(destination: actualLengthReg, source: bufferReg)
				
				// Move heap capability over the allocated region.
				Lower.Instruction.offsetCapability(destination: heapCapReg, source: heapCapReg, offset: actualLengthReg)
				
				// Store updated heap cap using heap cap cap.
				let heapCapCapReg2 = Lower.Register.t2	// shortening liveness by deriving it again
				Lower.Instruction.deriveCapabilityFromLabel(destination: heapCapCapReg2, label: heapCapLabel)
				Lower.Instruction.storeCapability(source: heapCapReg, address: heapCapCapReg2)
				
				// TODO: Clear authority.
				
				// Return to caller.
				Lower.Instruction.return
				
				// Heap capability.
				heapCapLabel ~ .nullCapability
				
				// Label end of routine.
				allocEndLabel ~ .signedWord(0)
				
			}
			
			// The user's region, consisting of code and authority.
			@StatementsBuilder
			var user: [Lower.Statement] {
				get throws {
					
					// User code.
					try effects.lowered(in: &context)
					
					// Alloc capability.
					userLabel ~ (allocCapLabel ~ .nullCapability)
					
					// Label end of user.
					userEndLabel ~ .signedWord(0)
					
				}
			}
			
			// The heap.
			@StatementsBuilder
			var heap: [Lower.Statement] {
				heapLabel ~ .filled(value: 0, datumByteSize: 1, copies: configuration.heapByteSize)
				heapEndLabel ~ .signedWord(0)
			}	// FIXME: Zeroed heap is emitted in ELF; define a (lazily zeroed) section instead?
			
			return try .init {
				initialisationRoutine	// requires & preserves alignment
				allocationRoutine		// requires & preserves alignment
				try user				// requires & consumes alignment
				heap					// does not require alignment
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
