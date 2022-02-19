// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation
import Sisp

public protocol Program : Codable, Equatable, Optimisable, CustomStringConvertible {
	
	/// Validates `self`.
	func validate() throws
	
	/// Returns a representation of `self` in a lower language.
	func lowered(configuration: CompilationConfiguration) throws -> LowerProgram
	
	/// A program in the lower language.
	associatedtype LowerProgram : Program
	
}

extension Program {
	
	public func write(to url: URL) throws {
		try SispEncoder()
			.encode(self)
			.serialised()
			.write(to: url, atomically: false, encoding: .utf8)
	}
	
	public var description: String {
		do {
			return try SispEncoder().encode(self).serialised()
		} catch {
			return "Could not serialise program: \(error)"
		}
	}
	
}

extension Never : Program {
	
	public init(from decoder: Decoder) throws {
		fatalError("Cannot decode an instance of Never")
	}
	
	public func encode(to encoder: Encoder) throws {
		switch self {}
	}
	
	public func optimise() -> Bool {
		switch self {}
	}
	
	public func validate() {
		switch self {}
	}
	
	public func lowered(configuration: CompilationConfiguration) -> Self {
		switch self {}
	}
	
}
