// Glyco © 2021–2022 Constantino Tsarouhas

import DepthKit

extension RV {
	
	/// A machine register.
	public enum Register : String, CaseIterable, Element {
		
		/// The always-zero register.
		case zero
		
		/// The return address register.
		case ra
		
		/// The stack capability register.
		case sp
		
		/// The global capability register (not used).
		case gp	// keep for ordinal
		
		/// The thread capability register (not used).
		case tp	// keep for ordinal
		
		/// A register for temporaries.
		case t0, t1, t2
		
		/// The frame capability register.
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
		public var c: String { self == .zero ? "cnull" : "c\(rawValue)" }
		
		/// The register's ordinal.
		public var ordinal: Int { Self.ordinalsByRegister[self] !! "Unknown register" }
		private static let ordinalsByRegister = [Self : Int](
			uniqueKeysWithValues: allCases.enumerated().map { ($0.element, $0.offset) }
		)
		
		/// A register for passing data through an invocation, i.e., `t6`/`ct6`.
		///
		/// The invocation data register contains a data capability after an invocation using a sealed code–data capability pair, but is also used as a dedicated argument register for some runtime routines.
		public static let invocationData = t6
		
	}
	
}
