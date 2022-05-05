// Glyco © 2021–2022 Constantino Tsarouhas

//sourcery: longname = Managed Memory
//sourcery: description = "A language that introduces a runtime, call stack, heap, and operations on them."
public enum MM : Language {
	
	/// An MM program.
	public struct Program : GlycoKit.Program {
		
		/// Creates a program with given effects.
		public init(_ effects: [Effect] = []) {
			self.effects = effects
		}
		
		/// The program's effects.
		public var effects: [Effect] = []
		
		// See protocol.
		public func optimise(configuration: CompilationConfiguration) -> Bool { false }
		
		// See protocol.
		public func validate(configuration: CompilationConfiguration) {}
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			
			var context = Context(configuration: configuration)
			
			let allocLabel = context.labels.uniqueName(from: "alloc")
			let allocEndLabel = context.labels.uniqueName(from: "alloc_end")
			let allocCapLabel = Label.allocationRoutineCapability
			
			let heapLabel = context.labels.uniqueName(from: "heap")
			let heapEndLabel = context.labels.uniqueName(from: "heap_end")
			let heapCapLabel = context.labels.uniqueName(from: "heap_cap")
			
			let stackLowLabel = context.labels.uniqueName(from: "stack_low")
			let stackHighLabel = context.labels.uniqueName(from: "stack_high")
			
			let csealLabel = context.labels.uniqueName(from: "cseal")
			let csealEndLabel = context.labels.uniqueName(from: "cseal_end")
			let csealCapLabel = Label.createSealRoutineCapability
			let csealSealCapLabel = context.labels.uniqueName(from: "cseal_seal_cap")
			
			let userEndLabel = context.labels.uniqueName(from: "user_end")
			
			// Implementation note: the following code is structured as to facilitate manual register allocation. #ohno
			
			// A routine that initialises the runtime, restricts the user's authority, and executes the user program. It touches all registers.
			@ArrayBuilder<Lower.Statement>
			var runtime: [Lower.Statement] {
				
				Lower.Statement.padding()
				
				// Initialise heap cap.
				do {
					
					// Derive heap cap.
					let heapCapReg = tempRegisterA
					(.runtime) ~ .deriveCapabilityFromLabel(destination: heapCapReg, label: heapLabel)
					
					// Restrict heap cap bounds.
					let heapEndCapReg = tempRegisterB
					let heapSizeReg = tempRegisterB
					Lower.Effect.deriveCapabilityFromLabel(destination: heapEndCapReg, label: heapEndLabel)
					Lower.Effect.getCapabilityDistance(destination: heapSizeReg, cs1: heapEndCapReg, cs2: heapCapReg)
					Lower.Effect.setCapabilityBounds(destination: heapCapReg, base: heapCapReg, length: .register(heapSizeReg))
					
					// Restrict heap cap permissions.
					let bitmaskReg = tempRegisterB
					Lower.Effect.permit(Self.heapCapabilityPermissions, destination: heapCapReg, source: heapCapReg, using: bitmaskReg)
					
					// Derive heap cap cap and store heap cap.
					let heapCapCapReg = tempRegisterB
					Lower.Effect.deriveCapabilityFromLabel(destination: heapCapCapReg, label: heapCapLabel)
					Lower.Effect.store(.cap, address: heapCapCapReg, source: heapCapReg, offset: 0)
					
				}
				
				// Initialise stack cap.
				if configuration.callingConvention.usesContiguousCallStack {
					
					// Derive stack cap.
					Lower.Effect.deriveCapabilityFromLabel(destination: .sp, label: stackLowLabel)
					
					// Restrict stack cap bounds.
					let stackHighCapReg = tempRegisterA
					let stackSizeReg = tempRegisterB
					Lower.Effect.deriveCapabilityFromLabel(destination: stackHighCapReg, label: stackHighLabel)
					Lower.Effect.getCapabilityDistance(destination: stackSizeReg, cs1: stackHighCapReg, cs2: .sp)
					Lower.Effect.setCapabilityBounds(destination: .sp, base: .sp, length: .register(stackSizeReg))
					
					// Move stack cap to upper bound since the stack grows downwards.
					let stackHighAddressReg = tempRegisterA
					Lower.Effect.getCapabilityAddress(destination: stackHighAddressReg, source: stackHighCapReg)
					Lower.Effect.setCapabilityAddress(destination: .sp, source: .sp, address: stackHighAddressReg)
					
					// Restrict stack cap permissions.
					let bitmaskReg = tempRegisterA
					Lower.Effect.permit(Self.stackCapabilityPermissions, destination: .sp, source: .sp, using: bitmaskReg)
					
				}
				
				// Initialise seal caps.
				do {
					
					// Derive seal cap from PCC.
					let sealCapReg = tempRegisterA
					Lower.Effect.deriveCapabilityFromPCC(destination: sealCapReg, upperBits: 0)
					
					// Restrict seal cap permissions.
					let bitmaskReg = tempRegisterB
					Lower.Effect.permit(Self.sealCapabilityPermissions, destination: sealCapReg, source: sealCapReg, using: bitmaskReg)
					
					// Assign first otype — it will be increased with every cseal.
					Lower.Effect.setCapabilityAddress(destination: sealCapReg, source: sealCapReg, address: .zero)
					
					// Derive cseal seal cap cap and store cseal seal cap.
					let csealSealCapCapReg = tempRegisterB
					Lower.Effect.deriveCapabilityFromLabel(destination: csealSealCapCapReg, label: csealSealCapLabel)
					Lower.Effect.store(.cap, address: csealSealCapCapReg, source: sealCapReg, offset: 0)
					
				}
				
				// Initialise alloc cap.
				do {
					
					// Derive alloc cap.
					let allocCapReg = tempRegisterA
					Lower.Effect.deriveCapabilityFromLabel(destination: allocCapReg, label: allocLabel)
					
					// Restrict alloc cap bounds.
					let allocCapEndReg = tempRegisterB
					let allocCapLengthReg = tempRegisterB
					Lower.Effect.deriveCapabilityFromLabel(destination: allocCapEndReg, label: allocEndLabel)
					Lower.Effect.getCapabilityDistance(destination: allocCapLengthReg, cs1: allocCapEndReg, cs2: allocCapReg)
					Lower.Effect.setCapabilityBounds(destination: allocCapReg, base: allocCapReg, length: .register(allocCapLengthReg))
					
					// Restrict alloc cap permissions.
					let bitmaskReg = tempRegisterB
					Lower.Effect.permit(Self.allocCapabilityPermissions, destination: allocCapReg, source: allocCapReg, using: bitmaskReg)
					Lower.Effect.sealEntry(destination: allocCapReg, source: allocCapReg)
					
					// Derive alloc cap cap and store alloc cap.
					let allocCapCapReg = tempRegisterB
					Lower.Effect.deriveCapabilityFromLabel(destination: allocCapCapReg, label: allocCapLabel)
					Lower.Effect.store(.cap, address: allocCapCapReg, source: allocCapReg, offset: 0)
					
				}
				
				// Initialise create seal cap.
				do {
					
					// Derive cseal cap.
					let csealCapReg = tempRegisterA
					Lower.Effect.deriveCapabilityFromLabel(destination: csealCapReg, label: csealLabel)
					
					// Restrict cseal cap bounds.
					let csealCapEndReg = tempRegisterB
					let csealCapLengthReg = tempRegisterB
					Lower.Effect.deriveCapabilityFromLabel(destination: csealCapEndReg, label: csealEndLabel)
					Lower.Effect.getCapabilityDistance(destination: csealCapLengthReg, cs1: csealCapEndReg, cs2: csealCapReg)
					Lower.Effect.setCapabilityBounds(destination: csealCapReg, base: csealCapReg, length: .register(csealCapLengthReg))
					
					// Restrict cseal cap permissions.
					let bitmaskReg = tempRegisterB
					Lower.Effect.permit(Self.csealCapabilityPermissions, destination: csealCapReg, source: csealCapReg, using: bitmaskReg)
					Lower.Effect.sealEntry(destination: csealCapReg, source: csealCapReg)
					
					// Derive cseal cap cap and store cseal cap.
					let csealCapCapReg = tempRegisterB
					Lower.Effect.deriveCapabilityFromLabel(destination: csealCapCapReg, label: csealCapLabel)
					Lower.Effect.store(.cap, address: csealCapCapReg, source: csealCapReg, offset: 0)
					
				}
				
				// Execute user program & return.
				do {
					
					// Derive program entry cap (so that we can restrict it before jumping to it).
					let programEntryReg = tempRegisterC	// survives cseal routine
					Lower.Effect.deriveCapabilityFromLabel(destination: programEntryReg, label: .programEntry)
					
					// Restrict user cap bounds.
					let userEndReg = tempRegisterA
					let userLengthReg = tempRegisterA
					Lower.Effect.deriveCapabilityFromLabel(destination: userEndReg, label: userEndLabel)
					Lower.Effect.getCapabilityDistance(destination: userLengthReg, cs1: userEndReg, cs2: programEntryReg)
					Lower.Effect.setCapabilityBounds(destination: programEntryReg, base: programEntryReg, length: .register(userLengthReg))
					
					// Restrict user cap permissions.
					let bitmaskReg = tempRegisterA
					Lower.Effect.permit(Self.userPPCPermissions, destination: programEntryReg, source: programEntryReg, using: bitmaskReg)
					
					// Call user program.
					switch configuration.callingConvention {
						
						case .conventional:
						Lower.Effect.clear([.fp])
						Lower.Effect.jump(to: .register(programEntryReg), link: .zero)
						// This is a tail-call so we don't link, thereaby avoiding the need to store the previous cra (to the OS) somewhere.
						
						case .heap:
						do {
							
							// Save return cap.
							let savedRA = context.labels.uniqueName(from: "savedRA")
							let savedRACapReg = tempRegisterA
							Lower.Effect.deriveCapabilityFromLabel(destination: savedRACapReg, label: savedRA)
							Lower.Effect.store(.cap, address: savedRACapReg, source: .ra, offset: 0)
							
							// Create fresh seal.
							let csealLinkReg = tempRegisterA			// cf. create seal routine
							let sealReg = Lower.Register.invocationData	// cf. create seal routine
							Lower.Effect.callRuntimeRoutine(capability: .createSealRoutineCapability, link: csealLinkReg)
							
							// Link & seal cra.
							let ret = context.labels.uniqueName(from: "ret")
							Lower.Effect.deriveCapabilityFromLabel(destination: .ra, label: ret)
							Lower.Effect.seal(destination: .ra, source: .ra, seal: sealReg)
							
							// Derive an arbitrary cfp & seal it.
							// The callee expects a valid, global, nonexecutable, cinvoke-able, sealed cap.
							let bitmaskReg = tempRegisterA
							Lower.Effect.deriveCapabilityFromPCC(destination: .fp, upperBits: 0)
							Lower.Effect.permit([.global, .invoke], destination: .fp, source: .fp, using: bitmaskReg)
							Lower.Effect.seal(destination: .fp, source: .fp, seal: sealReg)
							
							// Clear all registers except (selected) user authority.
							let preservedRegisters = [.ra, .fp, programEntryReg]	// Set is probably less efficient for merely 3 elements
							Lower.Effect.clear(Lower.Register.allCases.filter { !preservedRegisters.contains($0) })
							
							// Jump to callee (without linking again).
							Lower.Effect.jump(to: .register(programEntryReg), link: .zero)
							
							// Restore saved return cap.
							let savedRACapReg2 = tempRegisterA
							ret ~ .deriveCapabilityFromLabel(destination: savedRACapReg2, label: savedRA)
							Lower.Effect.load(.cap, destination: .ra, address: savedRACapReg2, offset: 0)
							
							// Return to OS/framework.
							Lower.Effect.jump(to: .register(.ra), link: .zero)
							
							// The saved return cap.
							Lower.Statement.padding(alignment: .cap)
							savedRA ~ .data(type: .cap)
							
						}
						
					}
					
				}
				
			}
			
			// A routine that allocates a buffer on the heap — see also MM.Label.allocationRoutineCapability.
			@ArrayBuilder<Lower.Statement>
			var allocationRoutine: [Lower.Statement] {
				
				let lengthReg = tempRegisterA	// argument
				let returnReg = tempRegisterB	// argument
				let bufferReg = tempRegisterA	// result — same register as length
				
				Lower.Statement.padding()
				
				// Round length up to nearest capability byte size multiple to ensure capability-aligned allocations.
				// Adapted from https://stackoverflow.com/a/1766566/732792
				let alignmentReg = tempRegisterC
				let alignmentMinusOne = DataType.cap.byteSize - 1	// 15
				allocLabel ~ Lower.Effect.compute(destination: alignmentReg, .zero, .add, .constant(alignmentMinusOne))	// M = 15
				Lower.Effect.compute(destination: lengthReg, lengthReg, .add, .register(alignmentReg))		// L = L + 15
				Lower.Effect.compute(destination: alignmentReg, alignmentReg, .xor, .constant(-1))			// M = ~15
				Lower.Effect.compute(destination: lengthReg, lengthReg, .and, .register(alignmentReg))		// L = (L + 15) & ~15
				
				// Derive heap cap cap and load heap cap.
				let heapCapCapReg1 = tempRegisterC
				let heapCapReg = tempRegisterC
				Lower.Effect.deriveCapabilityFromLabel(destination: heapCapCapReg1, label: heapCapLabel)
				Lower.Effect.load(.cap, destination: heapCapReg, address: heapCapCapReg1, offset: 0)
				
				// Derive buffer cap.
				Lower.Effect.setCapabilityBounds(destination: bufferReg, base: heapCapReg, length: .register(lengthReg))
				// FIXME: Align buffer to 16-byte boundaries to ensure that capabilities (and vectors/records thereof) are capability-aligned.
				
				// Determine (possibly rounded-up) length of allocated buffer.
				let actualLengthReg = tempRegisterD
				Lower.Effect.getCapabilityLength(destination: actualLengthReg, source: bufferReg)
				
				// Move heap capability over the allocated region.
				Lower.Effect.offsetCapability(destination: heapCapReg, source: heapCapReg, offset: .register(actualLengthReg))
				
				// Store updated heap cap using heap cap cap.
				let heapCapCapReg2 = tempRegisterD	// derive again to limit liveness
				Lower.Effect.deriveCapabilityFromLabel(destination: heapCapCapReg2, label: heapCapLabel)
				Lower.Effect.store(.cap, address: heapCapCapReg2, source: heapCapReg, offset: 0)
				
				// Clear authority.
				Lower.Effect.clear([heapCapReg, heapCapCapReg2])
				
				// Return to caller.
				Lower.Effect.jump(to: .register(returnReg), link: .zero)
				
				// Heap capability.
				Lower.Statement.padding(alignment: DataType.cap)
				heapCapLabel ~ .data(type: .cap)
				
				// Label end of routine.
				allocEndLabel ~ .padding()
				
			}
			
			// A routine that creates a new seal capability — see also MM.Label.secureCallingRoutineCapability.
			@ArrayBuilder<Lower.Statement>
			var createSealRoutine: [Lower.Statement] {
				
				let returnReg = tempRegisterA					// argument
				let sealCap = Lower.Register.invocationData		// result
				
				Lower.Statement.padding()
				
				// Load seal cap.
				let sealCapCap = tempRegisterB
				csealLabel ~ .deriveCapabilityFromLabel(destination: sealCapCap, label: csealSealCapLabel)
				Lower.Effect.load(.cap, destination: sealCap, address: sealCapCap, offset: 0)
				
				// Update seal cap for next invocation.
				Lower.Effect.offsetCapability(destination: sealCap, source: sealCap, offset: .constant(1))
				Lower.Effect.store(.cap, address: sealCapCap, source: sealCap, offset: 0)
				
				// Restrict bounds of seal cap to be returned.
				Lower.Effect.setCapabilityBounds(destination: sealCap, base: sealCap, length: .constant(1))
				
				// Clear authority.
				Lower.Effect.clear([sealCapCap])
				
				// Return.
				Lower.Effect.jump(to: .register(returnReg), link: .zero)
				
				// The seal capability.
				Lower.Statement.padding(alignment: DataType.cap)
				csealSealCapLabel ~ .data(type: .cap)
				
				// Label end of routine.
				csealEndLabel ~ .padding()
				
			}
			
			// The user's region, consisting of code and authority.
			@ArrayBuilder<Lower.Statement>
			var user: [Lower.Statement] {
				get throws {
					
					// User code.
					Lower.Statement.padding()
					try effects.lowered(in: &context)
					
					// Alloc capability.
					Lower.Statement.padding(alignment: DataType.cap)
					allocCapLabel ~ .data(type: .cap)
					
					// Create seal capability.
					csealCapLabel ~ .data(type: .cap)
					
					// Label end of user.
					userEndLabel ~ .padding()
					
				}
			}
			
			// The heap.
			@ArrayBuilder<Lower.Statement>
			var heap: [Lower.Statement] {
				Lower.Statement.padding(alignment: .cap)	// heap allocations are capability-aligned
				heapLabel ~ .data(type: .u8, count: configuration.heapByteSize)
				heapEndLabel ~ .padding()
			}
			
			// The stack.
			@ArrayBuilder<Lower.Statement>
			var stack: [Lower.Statement] {
				Lower.Statement.padding(alignment: .cap)	// stack frames are capability-aligned
				stackLowLabel ~ .data(type: .u8, count: configuration.stackByteSize.aligned(.cap))
				stackHighLabel ~ .padding()
			}
			
			return try .init {
				
				runtime
				allocationRoutine
				createSealRoutine
				try user
				
				Lower.Statement.bssSection
				heap
				if configuration.callingConvention.usesContiguousCallStack {
					stack
				}
				
			}
			
		}
		
		/// The stack capability's permissions.
		///
		/// Stack-allocated buffer capabilities derive their permissions directly from the stack capability; the runtime does not impose further restrictions. Allocated buffers can be passed as sealed parameters but cannot be used for code.
		private static let stackCapabilityPermissions = [Permission.load, .loadCapability, .store, .storeCapability, .storeLocalCapability, .invoke]
		
		/// The heap capability's permissions.
		///
		/// Heap-allocated buffer capabilities derive their permissions directly from the heap capability; the runtime does not impose further restrictions. Allocated buffers can be passed as sealed parameters but cannot be used for code.
		private static let heapCapabilityPermissions = [Permission.global, .load, .loadCapability, .store, .storeCapability, .invoke]
		
		/// The allocation routine capability's permissions.
		///
		/// The capability is used for executing the routine as well as to load & store (update) the heap capability which is stored inside the routine's memory region.
		private static let allocCapabilityPermissions = [Permission.global, .execute, .load, .loadCapability, .store, .storeCapability]
		
		/// The create seal routine capability's permissions.
		///
		/// The capability is used for executing the routine as well as to load & store (update) the seal capability which is stored inside the routine's memory region.
		private static let csealCapabilityPermissions = [Permission.global, .execute, .load, .loadCapability, .store, .storeCapability]
		
		/// The seal capabilities' permissions.
		private static let sealCapabilityPermissions = [Permission.global, .seal]
		
		/// The user's PPC capability permissions.
		private static let userPPCPermissions = [Permission.global, .execute, .load, .loadCapability, .store, .storeCapability, .invoke]
		
	}
	
	/// A temporary register reserved for MM.
	static let (tempRegisterA, tempRegisterB, tempRegisterC, tempRegisterD) = (Lower.Register.t0, Lower.Register.t1, Lower.Register.t2, Lower.Register.t3)
	
	// See protocol.
	public typealias Lower = RT
	
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias DataType = Lower.DataType
	public typealias Label = Lower.Label
	public typealias Permission = Lower.Permission
	
}

extension MM.Label {
	
	/// The label for the capability to the allocation routine.
	///
	/// The allocation routine takes a length in `MM.tempRegisterA`, a valid, executable return capability in `MM.tempRegisterB`, and returns a valid, capability-aligned buffer capability in `MM.tempRegisterA`. The routine may also touch any register reserved for MM, but will not leak any unintended new authority. `MM.tempRegisterB` **is not overwritten.**
	static var allocationRoutineCapability: Self { "mm.alloc_cap" }
	
	/// The label for the capability to the create seal routine.
	///
	/// The routine takes a valid, executable return capability in `MM.tempRegisterA` and returns a unique seal capability in `invocationData`. It may touch `MM.tempRegisterB` but will not leak any unintended new authority.
	static var createSealRoutineCapability: Self { "mm.cseal_cap" }
	
}
