// Glyco © 2021–2022 Constantino Tsarouhas

import Collections

extension FO {
	
	/// A machine register.
	public enum Register : String, Codable, Equatable, CaseIterable, SimplyLowerable {
		
		/// The default set of registers that can be used for storing data.
		///
		/// The order is semantically insignificant but it's fixed to make assignment more deterministic.
		static let defaultAssignableRegisters: OrderedSet = [Self.s1, .s2, .s3, .s4, .s5, .s6, .s7, .s8, .s9, .s10, .s11, .t4, .t5, .t6]
		
		/// The default set of registers that are used for passing arguments to procedures, in argument order.
		public static let defaultArgumentRegisters = [Self.a0, .a1, a2, a3, a4, a5, a6, a7]
		
		/// The default set of registers that can be used for passing results from procedures, in result value order.
		public static let defaultResultRegisters: OrderedSet = [Self.a0, .a1]
		
		/// The default set of registers that a procedure must discard or save before calling another procedure.
		public static let defaultCallerSavedRegisters = defaultArgumentRegisters + [.ra, .t4, .t5, .t6]
		
		/// The default set of registers that a procedure must save before using.
		public static let defaultCalleeSavedRegisters = [Self.s1, .s2, .s3, .s4, .s5, .s6, .s7, .s8, .s9, .s10, .s11]
		
		/// The always-zero register.
		case zero
		
		/// The return address register.
		case ra
		
		/// A saved register.
		case s1
		
		/// An argument or return value register.
		case a0, a1
		
		/// An argument register.
		case a2, a3, a4, a5, a6, a7
		
		/// A saved register.
		case s2, s3, s4, s5, s6, s7, s8, s9, s10, s11
		
		/// A register for temporaries.
		case t4, t5, t6
		
		// See protocol.
		func lowered(in context: inout ()) -> Lower.Register {
			switch self {
				case .zero:	return .zero
				case .ra:	return .ra
				case .s1:	return .s1
				case .a0:	return .a0
				case .a1:	return .a1
				case .a2:	return .a2
				case .a3:	return .a3
				case .a4:	return .a4
				case .a5:	return .a5
				case .a6:	return .a6
				case .a7:	return .a7
				case .s2:	return .s2
				case .s3:	return .s3
				case .s4:	return .s4
				case .s5:	return .s5
				case .s6:	return .s6
				case .s7:	return .s7
				case .s8:	return .s8
				case .s9:	return .s9
				case .s10:	return .s10
				case .s11:	return .s11
				case .t4:	return .t4
				case .t5:	return .t5
				case .t6:	return .t6
			}
		}
		
	}
	
}

extension FO.Register : Comparable {
	public static func < (lhs: Self, rhs: Self) -> Bool {
		lhs.rawValue < rhs.rawValue
	}
}
