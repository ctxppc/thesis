// Glyco © 2021–2022 Constantino Tsarouhas

extension MM {
	
	public enum RuntimeRoutine : String, Codable {
		
		/// A routine that performs a secure function call transition.
		///
		/// The scall routine takes a target capability in `ct0`, a return capability in `cra`, a frame capability in `cfp`, and function arguments in argument registers. It returns the same frame capability in `ct6` and any function results in argument registers.
		///
		/// The routine may touch any register but will not leak any new authority. The routine also clears `cfp` before jumping to the callee. Procedures are expected to perform appropriate register clearing before invoking the scall routine or before returning to the callee.
		///
		/// The callee receives a sealed return–frame capability pair in `cra` and `csp` as well as function arguments in argument registers, and returns function results in argument registers. It can return to the caller by invoking the return–frame capability pair.
		case scall
		
	}
	
}
