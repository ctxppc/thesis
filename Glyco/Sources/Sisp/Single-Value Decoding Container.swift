// Sisp © 2021–2022 Constantino Tsarouhas

import Foundation

/// A container over a single decodable value.
struct SingleValueDecodingContainer : Swift.SingleValueDecodingContainer {
	
	/// Creates a decoding container.
	init(decoder: SispDecoder) {
		self.decoder = decoder
	}
	
	/// The Sisp value from which to decode a value.
	private var sisp: Sisp { decoder.sisp }
	
	// See protocol.
	var codingPath: [CodingKey] { decoder.codingPath }
	
	/// The decoder.
	let decoder: SispDecoder
	
	// See protocol.
	func decodeNil() -> Bool {
		switch sisp {
			case .list([]):	return true
			default:		return false
		}
	}
	
	// See protocol.
	func decode(_ type: Bool.Type) throws -> Bool {
		guard case .string(let rawValue) = sisp, let value = Bool(rawValue) else {
			throw DecodingError.typeMismatch(
				Bool.self,
				.init(codingPath: codingPath, debugDescription: "Cannot decode Bool; found \(sisp.typeDescription) instead", underlyingError: nil)
			)
		}
		return value
	}
	
	// See protocol.
	func decode(_ type: String.Type) throws -> String {
		guard case .string(let value) = sisp else {
			throw DecodingError.typeMismatch(
				String.self,
				.init(codingPath: codingPath, debugDescription: "Cannot decode String; found \(sisp.typeDescription) instead", underlyingError: nil)
			)
		}
		return value
	}
	
	// See protocol.
	func decode(_ type: Double.Type) throws -> Double {
		.init(try integer())
	}
	
	// See protocol.
	func decode(_ type: Float.Type) throws -> Float {
		.init(try integer())
	}
	
	// See protocol.
	func decode(_ type: Int.Type) throws -> Int {
		try integer()
	}
	
	// See protocol.
	func decode(_ type: Int8.Type) throws -> Int8 {
		try integer()
	}
	
	// See protocol.
	func decode(_ type: Int16.Type) throws -> Int16 {
		try integer()
	}
	
	// See protocol.
	func decode(_ type: Int32.Type) throws -> Int32 {
		try integer()
	}
	
	// See protocol.
	func decode(_ type: Int64.Type) throws -> Int64 {
		try integer()
	}
	
	// See protocol.
	func decode(_ type: UInt.Type) throws -> UInt {
		try integer()
	}
	
	// See protocol.
	func decode(_ type: UInt8.Type) throws -> UInt8 {
		try integer()
	}
	
	// See protocol.
	func decode(_ type: UInt16.Type) throws -> UInt16 {
		try integer()
	}
	
	// See protocol.
	func decode(_ type: UInt32.Type) throws -> UInt32 {
		try integer()
	}
	
	// See protocol.
	func decode(_ type: UInt64.Type) throws -> UInt64 {
		try integer()
	}
	
	// See protocol.
	func decode<T : Decodable>(_ type: T.Type) throws -> T {
		do {
			return try T(from: decoder)
		} catch {
			if case .integer(let value) = sisp, let type = T.self as? (PartiallyIntDecodable).Type {
				return type.init(intValue: value) as! T
			} else if case .string(let stringValue) = sisp, let value = Bool(stringValue), let type = T.self as? (PartiallyBoolDecodable).Type {
				return type.init(boolValue: value) as! T
			} else if case .string(let value) = sisp, let type = T.self as? (PartiallyStringDecodable).Type {
				return type.init(stringValue: value) as! T
			} else {
				throw error
			}
		}
	}
	
	/// Extracts an integer from the Sisp value.
	private func integer<Integer : BinaryInteger>() throws -> Integer {
		guard case .integer(let value) = sisp else {
			throw DecodingError.typeMismatch(
				Integer.self,
				.init(codingPath: codingPath, debugDescription: "Cannot decode Bool; found \(sisp.typeDescription) instead", underlyingError: nil)
			)
		}
		guard let integer = Integer(exactly: value) else { throw Error.unrepresentableInteger(value: value, requestedType: "\(Integer.self)") }
		return integer
	}
	
	private enum Error : LocalizedError {
		
		/// An error indicating that a decoded integer cannot be represented in the requested type.
		case unrepresentableInteger(value: Int, requestedType: String)
		
		// See protocol.
		var errorDescription: String? {
			switch self {
				case .unrepresentableInteger(value: let value, requestedType: let requestedType):
				return "Cannot represent \(value) using \(requestedType)"
			}
		}
		
	}
	
}
