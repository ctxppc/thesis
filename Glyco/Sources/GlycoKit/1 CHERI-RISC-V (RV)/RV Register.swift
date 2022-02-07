// Glyco © 2021–2022 Constantino Tsarouhas

extension RV {
	
	/// A machine register.
	public enum Register : String, Codable, Equatable {
		
		/// The always-zero register.
		case zero
		
		/// The stack pointer register.
		case sp
		
		/// The global pointer register.
		case gp
		
		/// The thread pointer register.
		case tp
		
		/// A register for temporaries.
		case t0, t1, t2
		
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
		
		/// The integer register's identifier.
		public var x: String { rawValue }
		
		/// The capability register's identifier.
		public var c: String { "c\(rawValue)" }
		
	}
	
}
