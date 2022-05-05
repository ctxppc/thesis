// Glyco © 2021–2022 Constantino Tsarouhas

import Sisp

/// A program or an element thereof.
public protocol Element : Codable, Equatable, CustomStringConvertible {}

extension Element {
	public var description: String {
		do {
			return try SispEncoder().encode(self).serialised()
		} catch {
			return Mirror(reflecting: self).description
		}
	}
}
