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
		public func optimise(configuration: CompilationConfiguration) -> Bool { false }
		
		// See protocol.
		public func validate(configuration: CompilationConfiguration) {}
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			
			var context = Context(configuration: configuration)
			
			let allocLabel = context.labels.uniqueName(from: "mm.alloc")
			let allocEndLabel = context.labels.uniqueName(from: "mm.alloc.end")
			let allocCapLabel = Label.allocationRoutineCapability
			
			let heapLabel = context.labels.uniqueName(from: "mm.heap")
			let heapEndLabel = context.labels.uniqueName(from: "mm.heap.end")
			let heapCapLabel = context.labels.uniqueName(from: "mm.heap.cap")
			
			let stackLowLabel = context.labels.uniqueName(from: "mm.stack.low")
			let stackHighLabel = context.labels.uniqueName(from: "mm.stack.high")
			
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
					Lower.Effect.store(.cap, address: heapCapCapReg, source: heapCapReg)
					
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
				
				// Initialise seal cap.
				if configuration.callingConvention.requiresCallRoutine {
					
					// Derive seal cap from PCC.
					let sealCapReg = tempRegisterA
					Lower.Effect.deriveCapabilityFromPCC(destination: sealCapReg, upperBits: 0)
					
					// Restrict seal cap bounds to seal with otype 0 only.
					Lower.Effect.setCapabilityAddress(destination: sealCapReg, source: sealCapReg, address: .zero)
					Lower.Effect.setCapabilityBounds(destination: sealCapReg, base: sealCapReg, length: .constant(1))
					
					// Restrict seal cap permissions.
					let bitmaskReg = tempRegisterB
					Lower.Effect.permit(Self.sealCapabilityPermissions, destination: sealCapReg, source: sealCapReg, using: bitmaskReg)
					
					// Derive seal cap cap and store seal cap.
					let sealCapCapReg = tempRegisterB
					Lower.Effect.deriveCapabilityFromLabel(destination: sealCapCapReg, label: sealCapLabel)
					Lower.Effect.store(.cap, address: sealCapCapReg, source: sealCapReg)
					
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
					Lower.Effect.store(.cap, address: allocCapCapReg, source: allocCapReg)
					
				}
				
				// Initialise scall cap.
				if configuration.callingConvention.requiresCallRoutine {
					
					// Derive scall cap.
					let scallCapReg = tempRegisterA
					Lower.Effect.deriveCapabilityFromLabel(destination: scallCapReg, label: scallLabel)
					
					// Restrict scall cap bounds.
					let scallCapEndReg = tempRegisterB
					let scallCapLengthReg = tempRegisterB
					Lower.Effect.deriveCapabilityFromLabel(destination: scallCapEndReg, label: scallEndLabel)
					Lower.Effect.getCapabilityDistance(destination: scallCapLengthReg, cs1: scallCapEndReg, cs2: scallCapReg)
					Lower.Effect.setCapabilityBounds(destination: scallCapReg, base: scallCapReg, length: .register(scallCapLengthReg))
					
					// Restrict scall cap permissions.
					let bitmaskReg = tempRegisterB
					Lower.Effect.permit(Self.scallCapabilityPermissions, destination: scallCapReg, source: scallCapReg, using: bitmaskReg)
					Lower.Effect.sealEntry(destination: scallCapReg, source: scallCapReg)
					
					// Derive scall cap cap and store scall cap.
					let scallCapCapReg = tempRegisterB
					Lower.Effect.deriveCapabilityFromLabel(destination: scallCapCapReg, label: scallCapLabel)
					Lower.Effect.store(.cap, address: scallCapCapReg, source: scallCapReg)
					
				}
				
				// Execute user program & return.
				do {
					
					// Derive user cap.
					let userCapReg = Lower.Register.invocationData	// cf. scall routine
					Lower.Effect.deriveCapabilityFromLabel(destination: userCapReg, label: .programEntry)
					
					// Restrict user cap bounds.
					let userEndReg = tempRegisterA
					let userLengthReg = tempRegisterA
					Lower.Effect.deriveCapabilityFromLabel(destination: userEndReg, label: userEndLabel)
					Lower.Effect.getCapabilityDistance(destination: userLengthReg, cs1: userEndReg, cs2: userCapReg)
					Lower.Effect.setCapabilityBounds(destination: userCapReg, base: userCapReg, length: .register(userLengthReg))
					
					// Restrict user cap permissions.
					let bitmaskReg = tempRegisterA
					Lower.Effect.permit(Self.userPPCPermissions, destination: userCapReg, source: userCapReg, using: bitmaskReg)
					
					// Tail-call user program.
					switch configuration.callingConvention {
							
						case .conventional:
						Lower.Effect.copy(.cap, into: .fp, from: .zero)	// clear cfp
						Lower.Effect.jump(to: .register(userCapReg), link: .zero)
						// This is a tail-call so we don't link, thereaby avoiding the need to store the previous cra (to the OS) somewhere.
						
						case .heap:
						do {
							
							// cfp can be anything but must be a valid unsealed capability for the scall. (It will be sealed by the scall.)
							Lower.Effect.copy(.cap, into: .fp, from: userCapReg)
							
							// Clear all registers except (selected) user authority.
							let preservedRegisters = [.ra, .fp, userCapReg]	// Set is probably less efficient for merely 3 elements
							Lower.Effect.clear(Lower.Register.allCases.filter { !preservedRegisters.contains($0) })
							
							// Perform scall.
							let scallCapReg = tempRegisterA
							Lower.Effect.callRuntimeRoutine(capability: .secureCallingRoutineCapability, link: scallCapReg)
							// This is a tail-call so we don't link cra, but we can't pass .zero either, so we pass a free register instead.
							// By making this a tail-call we avoid having to store the previous cra somewhere or as a fake cfp arg to scall. No need for complexity here!
							
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
				
				// Derive heap cap cap and load heap cap.
				let heapCapCapReg = tempRegisterC
				let heapCapReg = tempRegisterD
				allocLabel ~ .deriveCapabilityFromLabel(destination: heapCapCapReg, label: heapCapLabel)
				Lower.Effect.load(.cap, destination: heapCapReg, address: heapCapCapReg)
				
				// Derive buffer cap.
				Lower.Effect.setCapabilityBounds(destination: bufferReg, base: heapCapReg, length: .register(lengthReg))
				
				// Determine (possibly rounded-up) length of allocated buffer.
				let actualLengthReg = tempRegisterD
				Lower.Effect.getCapabilityLength(destination: actualLengthReg, source: bufferReg)
				
				// Move heap capability over the allocated region.
				Lower.Effect.offsetCapability(destination: heapCapReg, source: heapCapReg, offset: .register(actualLengthReg))
				
				// Store updated heap cap using heap cap cap.
				Lower.Effect.store(.cap, address: heapCapCapReg, source: heapCapReg)
				
				// Clear authority.
				Lower.Effect.clear([heapCapReg, heapCapCapReg])
				
				// Return to caller.
				Lower.Effect.jump(to: .register(returnReg), link: returnReg)
				
				// Heap capability.
				heapCapLabel ~ .nullCapability
				
				// Label end of routine.
				allocEndLabel ~ .padding()
				
			}
			
			// A routine that performs a secure function call transition — see also MM.Label.secureCallingRoutineCapability.
			@ArrayBuilder<Lower.Statement>
			var scallRoutine: [Lower.Statement] {
				
				let targetReg = Lower.Register.invocationData	// input
				
				Lower.Statement.padding()
				
				// Load seal cap.
				let sealCapCap = tempRegisterA
				let sealCap = tempRegisterA
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
					Lower.Statement.padding()
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
			}
			
			// The stack.
			@ArrayBuilder<Lower.Statement>
			var stack: [Lower.Statement] {
				stackLowLabel ~ .filled(value: 0, datumByteSize: 1, copies: configuration.stackByteSize)
				stackHighLabel ~ .padding()
			}
			
			return try .init {
				
				runtime
				allocationRoutine
				if configuration.callingConvention.requiresCallRoutine {
					scallRoutine
				}
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
	/// The allocation routine takes a length in `MM.tempRegisterA`, a return capability in `MM.tempRegisterB`, and returns a buffer capability in `MM.tempRegisterA`. The routine may also touch `MM.tempRegisterC` and `MM.tempRegisterD` but will not leak any unintended new authority. `MM.tempRegisterB` **is not overwritten.**
	static var allocationRoutineCapability: Self { "mm.alloc.cap" }
	
	/// The label for the capability to the secure calling (scall) routine.
	///
	/// The scall routine takes a target capability in `invocationData`, a return capability in `cra`, a frame capability in `cfp`, and function arguments in argument registers. The target and return capabilities must be valid executable capabilities that are either unsealed or sentry capabilities. The frame capability must be a valid unsealed capability.
	///
	/// It returns the same frame capability in `invocationData` and any function results in argument registers.
	///
	/// The routine may touch any register but will not leak any unintended new authority. Procedures are expected to perform appropriate clearing of registers not used for arguments or for the scall itself before invoking the scall routine or before returning to the callee.
	///
	/// The callee receives a sealed return–frame capability pair in `cra` and `cfp` as well as function arguments in argument registers, and returns function results in argument registers. It can return to the caller by invoking the return–frame capability pair.
	static var secureCallingRoutineCapability: Self { "mm.scall.cap" }
	
}
