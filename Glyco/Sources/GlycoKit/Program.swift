// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation
import Sisp

public protocol Program : Codable, Equatable, Optimisable, CustomStringConvertible {
	
	/// Creates a program from given encoded representation.
	init(fromEncoded encoded: String) throws
	
	/// Validates `self`.
	func validate() throws
	
	/// Returns a representation of `self` in a lower language.
	func lowered(configuration: CompilationConfiguration) throws -> LowerProgram
	
	/// A program in the lower language.
	associatedtype LowerProgram : Program
	
	/// Returns an encoded representation of `self`.
	func encoded() throws -> String
	
}

extension Program {
	
	public init(fromEncoded encoded: String) throws {
		self = try SispDecoder(from: encoded).decode(Self.self)
	}
	
	public func encoded() throws -> String {
		try SispEncoder()
			.encode(self)
			.serialised()
	}
	
	public var description: String {
		do {
			return try encoded()
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
