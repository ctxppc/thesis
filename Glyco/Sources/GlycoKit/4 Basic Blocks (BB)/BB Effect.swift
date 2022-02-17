// Glyco © 2021–2022 Constantino Tsarouhas

extension BB {
	
	/// An effect on an BB machine.
	public enum Effect : Codable, Equatable, MultiplyLowerable {
		
		/// An effect that retrieves the value in `from` and puts it in `to`.
		case set(DataType, Location, to: Source)
		
		/// An effect that computes `lhs` `operation` `rhs` and puts it in `to`.
		case compute(Source, BinaryOperator, Source, to: Location)
		
		/// An effect that pushes a buffer of `bytes` bytes to the call frame and puts a capability for that buffer in given location.
		case allocateBuffer(bytes: Int, into: Location)
		
		/// An effect that retrieves the datum at offset `offset` in the buffer in `of` and puts it in `to`.
		case getElement(DataType, of: Location, offset: Source, to: Location)
		
		/// An effect that evaluates `to` and puts it in the buffer in `of` at offset `offset`.
		case setElement(DataType, of: Location, offset: Source, to: Source)
		
		/// An effect that retrieves the value from given source and pushes it to the call frame.
		case push(DataType, Source)
		
		/// An effect that removes `bytes` bytes from the stack.
		case pop(bytes: Int)
		
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
				
				case .allocateBuffer(bytes: let bytes, into: let buffer):
				return [.allocateBuffer(bytes: bytes, into: buffer)]
				
				case .getElement(let type, of: let vector, offset: let offset, to: let destination):
				return [.getElement(type, of: vector, offset: offset, to: destination)]
				
				case .setElement(let type, of: let vector, offset: let offset, to: let element):
				return [.setElement(type, of: vector, offset: offset, to: element)]
				
				case .push(let dataType, let source):
				return [.push(dataType, source)]
				
				case .pop(bytes: let bytes):
				return [.pop(bytes: bytes)]
				
				case .pushFrame(let frame):
				return [.pushFrame(frame)]
				
				case .popFrame:
				return [.popFrame]
				
			}
		}
		
	}
	
}
