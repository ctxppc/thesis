// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

extension NT {
	
	/// A globally scoped location.
	public struct GlobalDeclaration : Named, Codable, Equatable {
		
		/// The location's name.
		var name: Symbol
		
		/// The type of values stored at the location.
		var valueType: ValueType
		
		/// A Boolean value indicating whether the declaration is defined by the current module.
		///
		/// A declaration must be defined by exactly one module before it can be used.
		var defined: Bool
		
	}
	
}
