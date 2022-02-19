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
	
	/// Lowers `self` to S, encodes it into an object, and links it into an ELF executable.
	///
	/// This method must be implemented by languages that cannot be lowered. The default implementation lowers `self` and invokes `elf(configuration:)` on the lower language.
	func elf(configuration: CompilationConfiguration) throws -> Data
	
}

extension Program {
	
	public func elf(configuration: CompilationConfiguration) throws -> Data {
		try processedLowering(configuration: configuration)
			.elf(configuration: configuration)
	}
	
	/// Optionally optimises and validates `self`, then returns a representation of `self` in a lower language.
	public func processedLowering(configuration: CompilationConfiguration) throws -> LowerProgram {
		var copy = self
		if configuration.optimise {
			try copy.optimiseUntilFixedPoint()
		}
		if configuration.validate {
			try copy.validate()
		}
		return try copy.lowered(configuration: configuration)
	}
	
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
