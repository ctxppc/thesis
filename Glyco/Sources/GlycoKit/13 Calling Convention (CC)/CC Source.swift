// Glyco © 2021–2022 Constantino Tsarouhas

import Sisp

extension CC {
	
	/// A datum source.
	public enum Source : PartiallyStringCodable, PartiallyIntCodable, SimplyLowerable, Element {
		
		/// An integer with given value.
		case constant(Int)
		
		/// The value bound at given location.
		case location(Location)
		
		/// A capability pointing to given defined procedure.
		case procedure(Label)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Source {
			switch self {
				case .constant(let imm):		return .constant(imm)
				case .location(let location):	return .abstract(location)
				case .procedure(let name):		return .capability(to: name)
			}
		}
		
	}
	
}
