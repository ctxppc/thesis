// Glyco © 2021–2022 Constantino Tsarouhas

extension FL {
	
	/// A machine register.
	public enum Register : String, Codable, Equatable, SimplyLowerable {
		
		/// The always-zero register.
		case zero
		
		/// The return address register.
		case ra
		
		/// The stack pointer register.
		case sp
		
		/// The global pointer register.
		case gp
		
		/// The thread pointer register.
		case tp
		
		/// A register for temporaries.
		case t1, t2
		
		/// The frame pointer register.
		case fp
		
		/// A saved register.
		case s1
		
		/// An argument or return value register.
		case a0, a1
		
		/// An argument register.
		case a2, a3, a4, a5, a6, a7
		
		/// A saved register.
		case s2, s3, s4, s5, s6, s7, s8, s9, s10, s11
		
		/// A register for temporaries.
		case t3, t4, t5, t6
		
		// See protocol.
		func lowered(in context: inout ()) -> Lower.Register {
			switch self {
				case .zero:	return .zero
				case .ra:	return .ra
				case .sp:	return .sp
				case .gp:	return .gp
				case .tp:	return .tp
				case .t1:	return .t1
				case .t2:	return .t2
				case .fp:	return .fp
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
				case .t3:	return .t3
				case .t4:	return .t4
				case .t5:	return .t5
				case .t6:	return .t6
			}
		}
		
	}
	
}
