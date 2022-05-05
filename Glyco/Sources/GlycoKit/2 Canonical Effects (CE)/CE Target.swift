// Glyco © 2021–2022 Constantino Tsarouhas

import Sisp

extension CE {
	
	/// A jump target.
	public enum Target : PartiallyStringCodable, Element {
		
		/// The jump target is labelled.
		case label(Label)
		
		/// The jump target is provided by a capability in given register.
		case register(Register)
		
	}
	
}
