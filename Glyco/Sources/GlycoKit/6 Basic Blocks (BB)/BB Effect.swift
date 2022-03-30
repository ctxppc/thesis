// Glyco © 2021–2022 Constantino Tsarouhas

extension BB {
	
	/// An effect on an BB machine.
	public enum Effect : Codable, Equatable, SimplyLowerable {
		
		/// An effect that retrieves the value in `from` and puts it in `to`.
		case set(DataType, Location, to: Source)
		
		/// An effect that computes given expression and puts the result in given location.
		case compute(Location, Source, BinaryOperator, Source)
		
		/// An effect that allocates a buffer of `bytes` bytes and puts a capability for that buffer in given location.
		///
		/// If `onFrame` is `true`, the buffer may be allocated on the call frame and may be automatically deallocated when the frame is popped, after which it must not be accessed.
		case createBuffer(bytes: Int, capability: Location, onFrame: Bool)
		
		/// An effect that deallocates the buffer referred by the capability from given source.
		///
		/// This effect must only be used with buffers allocated in the current call frame. For any two buffers *a* and *b* allocated in the current call frame, *b* must be deallocated exactly once before deallocating *a*. Deallocation is not required before popping the call frame; in that case, deallocation is automatic.
		case destroyBuffer(capability: Source)
		
		/// An effect that retrieves the datum at offset `offset` in the buffer in `of` and puts it in `to`.
		case getElement(DataType, of: Location, offset: Source, to: Location)
		
		/// An effect that evaluates `to` and puts it in the buffer in `of` at offset `offset`.
		case setElement(DataType, of: Location, offset: Source, to: Source)
		
		/// An effect that creates a capability that can be used for sealing with a unique object type and puts it in given location.
		case createSeal(in: Location)
		
		/// Pushes given frame to the call stack.
		///
		/// This effect must be executed exactly once before any effects accessing the call frame.
		case pushFrame(Frame)
		
		/// Pops a frame from the call stack.
		///
		/// This effect must be executed exactly once before any effects accessing the previous call frame.
		case popFrame
		
		/// An effect that clears all registers except the structural registers `csp`, `cgp`, `ctp`, and `cfp` as well as given registers.
		case clearAll(except: [Register])
		
		// See protocol.
		func lowered(in context: inout ()) -> Lower.Effect {
			switch self {
				
				case .set(let type, let destination, to: let source):
				return .set(type, destination, to: source)
				
				case .compute(let destination, let lhs, let operation, let rhs):
				return .compute(destination, lhs, operation, rhs)
				
				case .createBuffer(bytes: let bytes, capability: let buffer, onFrame: let onFrame):
				return .createBuffer(bytes: bytes, capability: buffer, onFrame: onFrame)
				
				case .destroyBuffer(capability: let buffer):
				return .destroyBuffer(capability: buffer)
				
				case .getElement(let type, of: let vector, offset: let offset, to: let destination):
				return .getElement(type, of: vector, offset: offset, to: destination)
				
				case .setElement(let type, of: let vector, offset: let offset, to: let element):
				return .setElement(type, of: vector, offset: offset, to: element)
				
				case .createSeal(in: let destination):
				return .createSeal(in: destination)
				
				case .pushFrame(let frame):
				return .pushFrame(frame)
				
				case .popFrame:
				return .popFrame
				
				case .clearAll(except: let sparedRegisters):
				return .clearAll(except: sparedRegisters)
				
			}
		}
		
	}
	
}
