// Glyco © 2021–2022 Constantino Tsarouhas

import Collections

extension AL {
	
	/// A machine register.
	public enum Register : String, Codable, Equatable, CaseIterable, SimplyLowerable {
		
		/// Registers that are by default used for passing arguments to procedures, in argument order.
		public static let defaultArgumentRegisters = [Self.a0, .a1, a2, a3, a4, a5, a6, a7]
		
		/// Registers that can be used for passing results from procedures, in result value order.
		static let resultRegisters: OrderedSet = [Self.a0, .a1]
		
		/// The stack pointer register.
		case sp
		
		/// The frame pointer register.
		case fp
		
		/// An argument or return value register.
		case a0, a1
		
		/// An argument register.
		case a2, a3, a4, a5, a6, a7
		
		// See protocol.
		func lowered(in context: inout ()) -> Lower.Register {
			switch self {
				case .sp:	return .sp
				case .fp:	return .fp
				case .a0:	return .a0
				case .a1:	return .a1
				case .a2:	return .a2
				case .a3:	return .a3
				case .a4:	return .a4
				case .a5:	return .a5
				case .a6:	return .a6
				case .a7:	return .a7
			}
		}
		
	}
	
}

extension AL.Register : Comparable {
	public static func < (lhs: Self, rhs: Self) -> Bool {
		lhs.rawValue < rhs.rawValue
	}
}
