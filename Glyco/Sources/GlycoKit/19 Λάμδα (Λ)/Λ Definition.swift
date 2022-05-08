// Glyco © 2021–2022 Constantino Tsarouhas

import DepthKit
import OrderedCollections

extension Λ {
	
	/// A named value.
	public struct Definition : Element {
		
		/// Creates a definition with given name and value.
		public init(_ name: Symbol, _ value: Value) {
			self.name = name
			self.value = value
		}
		
		/// The definition's name.
		public var name: Symbol
		
		/// The definition's value.
		public var value: Value
		
		/// Returns a representation of `self` in the lower language.
		///
		/// - Requires: `lambdaLabelsBySymbol` contains a label for `name` if `value` is a lambda.
		///
		/// - Parameters:
		///   - context: The context wherein `self` is lowered.
		///   - lambdaLabelsBySymbol: A mapping of lambda symbols to function labels of lambdas defined in the same `let` value.
		///
		/// - Returns: A representation of `self` in the lower language.
		func lowered(in context: inout Context, lambdaLabelsBySymbol: OrderedDictionary<Lower.Symbol, Lower.Label>) throws -> Lower.Definition {
			if case .λ(takes: let parameters, returns: let resultType, in: let result) = value {
				let functionName = lambdaLabelsBySymbol[name] !! "Missing function label for lambda in let-value"
				context.lambdaFunctions.append(
					.init(functionName, takes: parameters, returns: resultType, in: .let(
						lambdaLabelsBySymbol.map { .init($0.key, .function($0.value)) }, // pseudo-closure of lambda (for recursion)
						in: try result.lowered(in: &context)
					))
				)
				return .init(name, .function(functionName))
			} else {
				return .init(name, try value.lowered(in: &context))
			}
		}
		
	}
	
}

extension Sequence where Element == Λ.Definition {
	func lowered(in context: inout Λ.Context) throws -> [Λ.Lower.Definition] {
		let lambdaLabelsBySymbol = OrderedDictionary<Λ.Lower.Symbol, Λ.Lower.Label>(uniqueKeysWithValues: compactMap { definition in
			guard case .λ = definition.value else { return nil }
			return (definition.name, context.labels.uniqueName(from: definition.name.rawValue))
		})
		return try map { try $0.lowered(in: &context, lambdaLabelsBySymbol: lambdaLabelsBySymbol) }
	}
}
