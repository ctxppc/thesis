// Glyco © 2021–2022 Constantino Tsarouhas

extension BB {
	
	/// An effect on an BB machine.
	public enum Effect : Codable, Equatable, MultiplyLowerable {
		
		/// An effect that retrieves the value in `from` and puts it in `to`.
		case set(DataType, Location, to: Source)
		
		/// An effect that computes `lhs` `operation` `rhs` and puts it in `to`.
		case compute(Source, BinaryOperator, Source, to: Location)
		
		/// An effect that retrieves the element at zero-based position `at` in the vector in `of` and puts it in `to`.
		case getElement(DataType, of: Location, at: Source, to: Location)
		
		/// An effect that evaluates `to` and puts it in the vector in `of` at zero-based position `at`.
		case setElement(DataType, of: Location, at: Source, to: Source)
		
		// See protocol.
		public func lowered(in context: inout ()) -> [Lower.Effect] {
			switch self {
				
				case .set(let type, let destination, to: let source):
				return [.set(type, destination, to: source)]
				
				case .compute(let lhs, let operation, let rhs, to: let destination):
				return [.compute(lhs, operation, rhs, to: destination)]
				
				case .getElement(let type, of: let vector, at: let index, to: let destination):
				return [.getElement(type, of: vector, at: index, to: destination)]
				
				case .setElement(let type, of: let vector, at: let index, to: let element):
				return [.setElement(type, of: vector, at: index, to: element)]
				
			}
		}
		
	}
	
}
