// Glyco © 2021 Constantino Tsarouhas

/// A machine register.
enum RVRegister : Int, Codable {
	
	/// The always-zero register.
	case zero = 0
	
	/// The return address register.
	case ra
	
	/// The stack pointer register.
	case sp
	
	/// The global pointer register.
	case gp
	
	/// The thread pointer register.
	case tp
	
	/// A register for temporaries.
	case t0, t1, t2
	
	/// The saved pointer register.
	case s0
	
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
	
}
