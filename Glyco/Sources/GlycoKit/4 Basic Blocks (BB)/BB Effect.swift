// Glyco © 2021–2022 Constantino Tsarouhas

extension BB {
	
	/// An effect on an BB machine.
	public enum Effect : Codable, Equatable, MultiplyLowerable {
		
		/// An effect that retrieves the value in `from` and puts it in `to`.
		case copy(from: Source, to: Location)
		
		/// An effect that computes `lhs` `operation` `rhs` and puts it in `to`.
		case compute(Source, BinaryOperator, Source, to: Location)
		
		/// An effect that retrieves the element at zero-based position `at` in the vector in `of` and puts it in `to`.
		case getElement(of: Location, at: Source, to: Location)
		
		/// An effect that evaluates `to` and puts it in the vector in `of` at zero-based position `at`.
		case setElement(of: Location, at: Source, to: Source)
		
		// See protocol.
		public func lowered(in context: inout ()) -> [Lower.Effect] {
			switch self {
				
				case .copy(from: let source, to: let destination):
				return [.copy(from: source, to: destination)]
				
				case .compute(let lhs, let operation, let rhs, to: let destination):
				return [.compute(lhs, operation, rhs, to: destination)]
				
				case .getElement(of: let vector, at: let index, to: let destination):
				TODO.unimplemented
				
				case .setElement(of: let vector, at: let index, to: let element):
				TODO.unimplemented
				
			}
		}
		
	}
	
}
