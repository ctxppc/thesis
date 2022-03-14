// Glyco © 2021–2022 Constantino Tsarouhas

//sourcery: longname = Managed Memory
//sourcery: description = "A language that introduces a runtime, call stack, heap, and operations on them."
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
			
			let allocLabel = context.labels.uniqueName(from: "mm.alloc")
			let allocEndLabel = context.labels.uniqueName(from: "mm.alloc.end")
			let allocCapLabel = Label.allocationRoutineCapability
			
			let heapLabel = context.labels.uniqueName(from: "mm.heap")
			let heapEndLabel = context.labels.uniqueName(from: "mm.heap.end")
			let heapCapLabel = context.labels.uniqueName(from: "mm.heap.cap")
			
			let stackLabel = context.labels.uniqueName(from: "mm.stack")
			let stackEndLabel = context.labels.uniqueName(from: "mm.stack.end")
			
			let scallLabel = context.labels.uniqueName(from: "mm.scall")
			let scallEndLabel = context.labels.uniqueName(from: "mm.scall.end")
			let scallCapLabel = Label.secureCallingRoutineCapability
			let sealCapLabel = context.labels.uniqueName(from: "mm.seal.cap")
			
			let userLabel = context.labels.uniqueName(from: "mm.user")
			let userEndLabel = context.labels.uniqueName(from: "mm.user.end")
			
			// Implementation note: the following code is structured as to facilitate manual register allocation. #ohno
			
			// A routine that initialises the runtime, restricts the user's authority, and executes the user program. It touches all registers.
			@ArrayBuilder<Lower.Statement>
			var runtime: [Lower.Statement] {
				
				// Initialise heap cap.
				do {
					
					// Derive heap cap.
					let heapCapReg = Lower.Register.t0
					(.runtime) ~ .deriveCapabilityFromLabel(destination: heapCapReg, label: heapLabel)
					
					// Restrict heap cap bounds.
					let heapCapEndReg = Lower.Register.t1
					let heapCapLengthReg = Lower.Register.t1
					Lower.Effect.deriveCapabilityFromLabel(destination: heapCapEndReg, label: heapEndLabel)
					Lower.Effect.getCapabilityDistance(destination: heapCapLengthReg, cs1: heapCapEndReg, cs2: heapCapReg)
					Lower.Effect.setCapabilityBounds(destination: heapCapReg, source: heapCapReg, length: .register(heapCapLengthReg))
					
					// Restrict heap cap permissions.
					let bitmaskReg = Lower.Register.t1
					Lower.Effect.permit(Self.heapCapabilityPermissions, destination: heapCapReg, source: heapCapReg, using: bitmaskReg)
					
					// Derive heap cap cap and store heap cap.
					let heapCapCapReg = Lower.Register.t1
					Lower.Effect.deriveCapabilityFromLabel(destination: heapCapCapReg, label: heapCapLabel)
					Lower.Effect.store(.cap, address: heapCapCapReg, source: heapCapReg)
					
				}
				
				// Initialise stack cap.
				if configuration.callingConvention.usesContiguousCallStack {
					
					// Derive stack cap.
					Lower.Effect.deriveCapabilityFromLabel(destination: .sp, label: stackLabel)
					
					// Restrict stack cap bounds.
					let stackCapEndReg = Lower.Register.t1
					let stackCapLengthReg = Lower.Register.t1
					Lower.Effect.deriveCapabilityFromLabel(destination: stackCapEndReg, label: stackEndLabel)
					Lower.Effect.getCapabilityDistance(destination: stackCapLengthReg, cs1: stackCapEndReg, cs2: .sp)
					Lower.Effect.setCapabilityBounds(destination: .sp, source: .sp, length: .register(stackCapLengthReg))
					
					// Restrict stack cap permissions.
					let bitmaskReg = Lower.Register.t1
					Lower.Effect.permit(Self.stackCapabilityPermissions, destination: .sp, source: .sp, using: bitmaskReg)
					
				}
				
				// Initialise seal cap.
				if configuration.callingConvention.requiresCallRoutine {
					
					// Derive seal cap from PCC.
					let sealCapReg = Lower.Register.t0
					Lower.Effect.deriveCapabilityFromPCC(destination: sealCapReg, upperBits: 0)
					
					// Restrict seal cap bounds to seal with otype 0 only.
					Lower.Effect.setCapabilityAddress(destination: sealCapReg, source: sealCapReg, address: .zero)
					Lower.Effect.setCapabilityBounds(destination: sealCapReg, source: sealCapReg, length: .constant(1))
					
					// Restrict seal cap permissions.
					let bitmaskReg = Lower.Register.t1
					Lower.Effect.permit(Self.sealCapabilityPermissions, destination: sealCapReg, source: sealCapReg, using: bitmaskReg)
					
					// Derive seal cap cap and store seal cap.
					let sealCapCapReg = Lower.Register.t1
					Lower.Effect.deriveCapabilityFromLabel(destination: sealCapCapReg, label: sealCapLabel)
					Lower.Effect.store(.cap, address: sealCapCapReg, source: sealCapReg)
					
				}
				
				// Initialise alloc cap.
				do {
					
					// Derive alloc cap.
					let allocCapReg = Lower.Register.t0
					Lower.Effect.deriveCapabilityFromLabel(destination: allocCapReg, label: allocLabel)
					
					// Restrict alloc cap bounds.
					let allocCapEndReg = Lower.Register.t1
					let allocCapLengthReg = Lower.Register.t1
					Lower.Effect.deriveCapabilityFromLabel(destination: allocCapEndReg, label: allocEndLabel)
					Lower.Effect.getCapabilityDistance(destination: allocCapLengthReg, cs1: allocCapEndReg, cs2: allocCapReg)
					Lower.Effect.setCapabilityBounds(destination: allocCapReg, source: allocCapReg, length: .register(allocCapLengthReg))
					
					// Restrict alloc cap permissions.
					let bitmaskReg = Lower.Register.t1
					Lower.Effect.permit(Self.allocCapabilityPermissions, destination: allocCapReg, source: allocCapReg, using: bitmaskReg)
					Lower.Effect.sealEntry(destination: allocCapReg, source: allocCapReg)
					
					// Derive alloc cap cap and store alloc cap.
					let allocCapCapReg = Lower.Register.t1
					Lower.Effect.deriveCapabilityFromLabel(destination: allocCapCapReg, label: allocCapLabel)
					Lower.Effect.store(.cap, address: allocCapCapReg, source: allocCapReg)
					
				}
				
				// Initialise scall cap.
				if configuration.callingConvention.requiresCallRoutine {
					
					// Derive scall cap.
					let scallCapReg = Lower.Register.t0
					Lower.Effect.deriveCapabilityFromLabel(destination: scallCapReg, label: scallLabel)
					
					// Restrict scall cap bounds.
					let scallCapEndReg = Lower.Register.t1
					let scallCapLengthReg = Lower.Register.t1
					Lower.Effect.deriveCapabilityFromLabel(destination: scallCapEndReg, label: scallEndLabel)
					Lower.Effect.getCapabilityDistance(destination: scallCapLengthReg, cs1: scallCapEndReg, cs2: scallCapReg)
					Lower.Effect.setCapabilityBounds(destination: scallCapReg, source: scallCapReg, length: .register(scallCapLengthReg))
					
					// Restrict scall cap permissions.
					let bitmaskReg = Lower.Register.t1
					Lower.Effect.permit(Self.scallCapabilityPermissions, destination: scallCapReg, source: scallCapReg, using: bitmaskReg)
					Lower.Effect.sealEntry(destination: scallCapReg, source: scallCapReg)
					
					// Derive scall cap cap and store scall cap.
					let scallCapCapReg = Lower.Register.t1
					Lower.Effect.deriveCapabilityFromLabel(destination: scallCapCapReg, label: scallCapLabel)
					Lower.Effect.store(.cap, address: scallCapCapReg, source: scallCapReg)
					
				}
				
				// Execute user program & return.
				do {
					
					// Derive user cap.
					let userCapReg = Lower.Register.invocationData
					Lower.Effect.deriveCapabilityFromLabel(destination: userCapReg, label: .programEntry)
					
					// Restrict user cap bounds.
					let userEndReg = Lower.Register.t0
					let userLengthReg = Lower.Register.t0
					Lower.Effect.deriveCapabilityFromLabel(destination: userEndReg, label: userEndLabel)
					Lower.Effect.getCapabilityDistance(destination: userLengthReg, cs1: userEndReg, cs2: userCapReg)
					Lower.Effect.setCapabilityBounds(destination: userCapReg, source: userCapReg, length: .register(userLengthReg))
					
					// Restrict user cap permissions.
					let bitmaskReg = Lower.Register.t0
					Lower.Effect.permit(Self.userPPCPermissions, destination: userCapReg, source: userCapReg, using: bitmaskReg)
					
					// Call user program.
					switch configuration.callingConvention {
							
						case .conventional:
						Lower.Effect.jump(to: .register(userCapReg), link: .ra)
						
						case .heap:
						do {
							
							// Copy cra to cfp to preserve it across the scall — we don't need an actual frame in the runtime.
							let savedRABeforeScallReg = Lower.Register.fp
							Lower.Effect.copy(.cap, into: savedRABeforeScallReg, from: .ra)
							
							// Clear all registers except (selected) user authority.
							let preservedRegisters = [savedRABeforeScallReg, userCapReg]	// Set is probably less efficient for 2 elements
							Lower.Effect.clear(Lower.Register.allCases.filter { !preservedRegisters.contains($0) })
							
							// Perform scall.
							let scallCapReg = Lower.Register.t0
							Lower.Effect.callRuntimeRoutine(.secureCallingRoutineCapability, using: scallCapReg)
							
							// Return to OS/framework.
							let savedRAAfterScallReg = Lower.Register.invocationData
							Lower.Effect.jump(to: .register(savedRAAfterScallReg), link: .zero)
							
						}
							
					}
					
				}
				
			}
			
			// A routine that allocates a buffer on the heap — see also MM.Label.allocationRoutineCapability.
			@ArrayBuilder<Lower.Statement>
			var allocationRoutine: [Lower.Statement] {
				
				let lengthReg = Lower.Register.t0	// input
				let bufferReg = Lower.Register.t0	// output (same location as input)
				
				// Derive heap cap cap and load heap cap.
				let heapCapCapReg1 = Lower.Register.t1
				let heapCapReg = Lower.Register.t1
				allocLabel ~ .deriveCapabilityFromLabel(destination: heapCapCapReg1, label: heapCapLabel)
				Lower.Effect.load(.cap, destination: heapCapReg, address: heapCapCapReg1)
				
				// Derive buffer cap into ca0 using length in a0.
				Lower.Effect.setCapabilityBounds(destination: bufferReg, source: heapCapReg, length: .register(lengthReg))
				
				// Determine (possibly rounded-up) length of allocated buffer.
				let actualLengthReg = Lower.Register.t2
				Lower.Effect.getCapabilityLength(destination: actualLengthReg, source: bufferReg)
				
				// Move heap capability over the allocated region.
				Lower.Effect.offsetCapability(destination: heapCapReg, source: heapCapReg, offset: .register(actualLengthReg))
				
				// Store updated heap cap using heap cap cap.
				let heapCapCapReg2 = Lower.Register.t2	// shortening liveness by deriving it again
				Lower.Effect.deriveCapabilityFromLabel(destination: heapCapCapReg2, label: heapCapLabel)
				Lower.Effect.store(.cap, address: heapCapCapReg2, source: heapCapReg)
				
				// Clear authority.
				Lower.Effect.clear([heapCapReg, heapCapCapReg2])
				
				// Return to caller.
				Lower.Effect.return
				
				// Heap capability.
				heapCapLabel ~ .nullCapability
				
				// Label end of routine.
				allocEndLabel ~ .padding()
				
			}
			
			// A routine that performs a secure function call transition — see also MM.Label.secureCallingRoutineCapability.
			@ArrayBuilder<Lower.Statement>
			var scallRoutine: [Lower.Statement] {
				
				let targetReg = Lower.Register.invocationData	// input
				
				// Load seal cap.
				let sealCapCap = Lower.Register.t1
				let sealCap = Lower.Register.t1
				scallLabel ~ .deriveCapabilityFromLabel(destination: sealCapCap, label: sealCapLabel)
				Lower.Effect.load(.cap, destination: sealCap, address: sealCapCap)
				
				// Seal return & frame capabilities.
				Lower.Effect.seal(destination: .ra, source: .ra, seal: sealCap)
				Lower.Effect.seal(destination: .fp, source: .fp, seal: sealCap)
				
				// Clear authority.
				Lower.Effect.clear([sealCap])
				
				// Jump to callee — while preserving link.
				Lower.Effect.jump(to: .register(targetReg), link: .zero)
				
				// The seal capability.
				sealCapLabel ~ .nullCapability
				
				// Label end of routine.
				scallEndLabel ~ .padding()
				
			}
			
			// The user's region, consisting of code and authority.
			@ArrayBuilder<Lower.Statement>
			var user: [Lower.Statement] {
				get throws {
					
					// Alloc capability.
					userLabel ~ (allocCapLabel ~ .nullCapability)
					
					// Scall capability.
					scallCapLabel ~ .nullCapability
					
					// User code.
					try effects.lowered(in: &context)
					
					// Label end of user.
					userEndLabel ~ .padding()
					
				}
			}
			
			// The heap.
			@ArrayBuilder<Lower.Statement>
			var heap: [Lower.Statement] {
				heapLabel ~ .filled(value: 0, datumByteSize: 1, copies: configuration.heapByteSize)
				heapEndLabel ~ .padding()
			}	// FIXME: Zeroed heap is emitted in ELF; define a (lazily zeroed) section instead?
			
			// The stack.
			@ArrayBuilder<Lower.Statement>
			var stack: [Lower.Statement] {
				stackLabel ~ .filled(value: 0, datumByteSize: 1, copies: configuration.stackByteSize)
				stackEndLabel ~ .padding()
			}	// FIXME: Zeroed stack is emitted in ELF; define a (lazily zeroed) section instead?
			
			return try .init {
				runtime					// requires & preserves 4-byte alignment
				allocationRoutine		// requires & preserves 4-byte alignment
				if configuration.callingConvention.requiresCallRoutine {
					scallRoutine		// requires & preserves 4-byte alignment
				}
				try user				// requires & preserves 4-byte alignment
				heap					// does not require alignment
				if configuration.callingConvention.usesContiguousCallStack {
					stack				// does not require alignment
				}
			}
			
		}
		
		/// The stack capability's permissions.
		///
		/// Stack-allocated buffer capabilities derive their permissions directly from the stack capability; the runtime does not impose further restrictions.
		static let stackCapabilityPermissions = [Permission.load, .loadCapability, .store, .storeCapability]
		
		/// The heap capability's permissions.
		///
		/// Heap-allocated buffer capabilities derive their permissions directly from the heap capability; the runtime does not impose further restrictions.
		static let heapCapabilityPermissions = [Permission.load, .loadCapability, .store, .storeCapability]
		
		/// The allocation routine capability's permissions.
		///
		/// The capability is used for executing the routine as well as to load & store (update) the heap capability which is stored inside the routine's memory region.
		static let allocCapabilityPermissions = [Permission.loadCapability, .storeCapability, .execute]
		
		/// The secure calling routine capability's permissions.
		///
		/// The capability is used for executing the routine as well as to load the seal capability which is stored inside the routine's memory region.
		static let scallCapabilityPermissions = [Permission.loadCapability, .execute]
		
		/// The seal capability's permissions.
		static let sealCapabilityPermissions = [Permission.seal]
		
		/// The user's PPC capability permissions.
		static let userPPCPermissions = [Permission.load, .execute, .invoke]
		
	}
	
	// See protocol.
	public typealias Lower = RT
	
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias DataType = Lower.DataType
	public typealias Label = Lower.Label
	public typealias Permission = Lower.Permission
	
}
