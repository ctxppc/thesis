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
		
		/// An effect that retrieves the datum at offset `at` in the buffer in `of` and puts it in `to`.
		case getElement(DataType, of: Location, at: Source, to: Location)
		
		/// An effect that evaluates `to` and puts it in the buffer in `of` at offset `at`.
		case setElement(DataType, of: Location, at: Source, to: Source)
		
		/// An effect that retrieves the value from given source and pushes it to the call frame.
		case push(DataType, Source)
		
		/// An effect that removes `bytes` bytes from the stack.
		case pop(bytes: Int)
		
		/// Pushes a frame of size `bytes` bytes to the call stack.
		///
		/// This effect must be executed exactly once before any effects accessing the call frame.
		case pushFrame(bytes: Int)
		
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
				
				case .getElement(let type, of: let vector, at: let index, to: let destination):
				return [.getElement(type, of: vector, at: index, to: destination)]
				
				case .setElement(let type, of: let vector, at: let index, to: let element):
				return [.setElement(type, of: vector, at: index, to: element)]
				
				case .push(let dataType, let source):
				return [.push(dataType, source)]
				
				case .pop(bytes: let bytes):
				return [.pop(bytes: bytes)]
				
				case .pushFrame(bytes: let bytes):
				return [.pushFrame(bytes: bytes)]
				
				case .popFrame:
				return [.popFrame]
				
			}
		}
		
	}
	
}
