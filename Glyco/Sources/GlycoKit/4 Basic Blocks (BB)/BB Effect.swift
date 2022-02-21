// Glyco © 2021–2022 Constantino Tsarouhas

extension BB {
	
	/// An effect on an BB machine.
	public enum Effect : Codable, Equatable, MultiplyLowerable {
		
		/// An effect that retrieves the value in `from` and puts it in `to`.
		case set(DataType, Location, to: Source)
		
		/// An effect that computes `lhs` `operation` `rhs` and puts it in `to`.
		case compute(Source, BinaryOperator, Source, to: Location)
		
		/// An effect that pushes a buffer of `bytes` bytes to the call frame and puts a capability for that buffer in given location.
		case pushBuffer(bytes: Int, into: Location)
		
		/// An effect that pops the buffer referred by the capability from given source.
		///
		/// This effect must only be used with buffers allocated in the current call frame. For any two buffers *a* and *b* allocated in the current call frame, *b* must be deallocated exactly once before deallocating *a*. Deallocation is not required before popping the call frame; in that case, deallocation is automatic.
		case popBuffer(Source)
		
		/// An effect that retrieves the datum at offset `offset` in the buffer in `of` and puts it in `to`.
		case getElement(DataType, of: Location, offset: Source, to: Location)
		
		/// An effect that evaluates `to` and puts it in the buffer in `of` at offset `offset`.
		case setElement(DataType, of: Location, offset: Source, to: Source)
		
		/// Pushes given frame to the call stack.
		///
		/// This effect must be executed exactly once before any effects accessing the call frame.
		case pushFrame(Frame)
		
		/// Pops a frame from the call stack.
		///
		/// This effect must be executed exactly once before any effects accessing the previous call frame.
		case popFrame
		
		// See protocol.
		func lowered(in context: inout ()) -> [Lower.Effect] {
			switch self {
				
				case .set(let type, let destination, to: let source):
				return [.set(type, destination, to: source)]
				
				case .compute(let lhs, let operation, let rhs, to: let destination):
				return [.compute(lhs, operation, rhs, to: destination)]
				
				case .pushBuffer(bytes: let bytes, into: let buffer):
				return [.pushBuffer(bytes: bytes, into: buffer)]
				
				case .popBuffer(let buffer):
				return [.popBuffer(buffer)]
				
				case .getElement(let type, of: let vector, offset: let offset, to: let destination):
				return [.getElement(type, of: vector, offset: offset, to: destination)]
				
				case .setElement(let type, of: let vector, offset: let offset, to: let element):
				return [.setElement(type, of: vector, offset: offset, to: element)]
				
				case .pushFrame(let frame):
				return [.pushFrame(frame)]
				
				case .popFrame:
				return [.popFrame]
				
			}
		}
		
	}
	
}
