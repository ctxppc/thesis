// Glyco © 2021–2022 Constantino Tsarouhas

import GlycoKit
import Sisp
import XCTest

final class IntermediateProgramsTestCase : XCTestCase {
	
	func testPrograms() throws {
		for target in CompilationConfiguration.Target.allCases {
			for convention in CompilationConfiguration.CallingConvention.allCases {
				try verifyPrograms(
					programsURL:	.init(fileURLWithPath: "Tests/Test Programs/\(convention).\(target)"),
					configuration:	.init(target: target, callingConvention: convention)
				)
			}
		}
	}
	
	func verifyPrograms(programsURL: URL, configuration: CompilationConfiguration) throws {
		
		guard let urls = try? FileManager.default.contentsOfDirectory(at: programsURL, includingPropertiesForKeys: nil) else { return }
		let urlsByGroupName = Dictionary(grouping: urls) { $0.deletingPathExtension().lastPathComponent }
		var errors = TestErrors(configuration: configuration)
		
		print("> Testing \(urlsByGroupName.count) test programs for \(configuration)")
		for (groupName, urls) in urlsByGroupName where !groupName.starts(with: ".") {
			do {
				print(">> Testing “\(groupName)”, ", terminator: "")
				var programSispsByLanguageName = Dictionary(uniqueKeysWithValues: try urls.compactMap { url -> (String, String)? in
					let language = url.pathExtension.uppercased()
					guard !language.isEmpty, language != "OUT" else { return nil }
					return (language, try .init(contentsOf: url))
				})
				if programSispsByLanguageName.count < 2 {
					print("which does not have any additional intermediate programs to test against… skipped")
					continue
				}
				print("consisting of \(programSispsByLanguageName.count) intermediate programs… ", terminator: "")
				try HighestSupportedLanguage.iterate(
					DecodeSourceAndTestIntermediateProgramsAction(programSispsByLanguageName: programSispsByLanguageName, configuration: configuration)
				)
				print("OK")
			} catch {
				print("failed")
				errors.add(.init(groupName: groupName, error: error))
			}
		}
		
		if !errors.isEmpty {
			throw errors
		}
		
	}
	
	struct TestErrors : Error, CustomStringConvertible {
		
		let configuration: CompilationConfiguration
		
		var errors = [TestGroupError]()
		
		var isEmpty: Bool { errors.isEmpty }
		
		mutating func add(_ error: TestGroupError) {
			errors.append(error)
		}
		
		var description: String { """
			
			Errors for \(configuration):
			\(errors.lazy.map(\.description).joined(separator: "\n"))
			
			"""
		}
		
	}
	
	struct TestGroupError : Error, CustomStringConvertible {
		let groupName: String
		let error: Error
		var description: String { "(*) Test for “\(groupName)” failed: \(error)" }
	}
	
}

private struct DecodeSourceAndTestIntermediateProgramsAction : LanguageAction {
	
	let programSispsByLanguageName: [String : String]
	let configuration: CompilationConfiguration
	
	func callAsFunction<L : Language>(language: L.Type) throws -> ()? {
		var programSispsByLanguageName = programSispsByLanguageName
		guard let programSisp = programSispsByLanguageName.removeValue(forKey: language.name) else { return nil }
		let sourceProgram: L.Program
		do {
			sourceProgram = try SispDecoder(from: programSisp).decode(L.Program.self)
		} catch {
			throw TestSourceError(languageName: language.name, error: error)
		}
		try L.reduce(sourceProgram, using: IntermediateProgramsTestReductor(programSispsByLanguageName: programSispsByLanguageName), configuration: configuration)
		return ()
	}
	
	struct TestSourceError : Error, CustomStringConvertible {
		let languageName: String
		let error: Error
		var description: String { "while decoding \(languageName) source program: \(error)" }
	}
	
}

private struct IntermediateProgramsTestReductor : ProgramReductor {
	
	var programSispsByLanguageName: [String : String]
	
	mutating func update<L : Language>(language: L.Type, program actual: L.Program) throws -> ()? {
		do {
			if programSispsByLanguageName.isEmpty {
				return ()
			} else if let expectedProgramSisp = programSispsByLanguageName.removeValue(forKey: language.name) {
				let expected = try L.Program(fromEncoded: expectedProgramSisp)
				XCTAssertEqual(actual, expected)
				return nil
			} else {
				return nil
			}
		} catch {
			throw IntermediateProgramError.decodingError(error, languageName: language.name)
		}
	}
	
	func result() throws {
		if !programSispsByLanguageName.isEmpty {
			throw IntermediateProgramError.unrecognisedLanguages(.init(programSispsByLanguageName.keys))
		}
	}
	
	enum IntermediateProgramError : Error, CustomStringConvertible {
		case decodingError(Error, languageName: String)
		case unrecognisedLanguages(Set<String>)
		var description: String {
			switch self {
				
				case .decodingError(let error, languageName: let languageName):
				return "while decoding intermediate \(languageName) program: \(error)"
				
				case .unrecognisedLanguages(let languages):
				return "unrecognised languages \(languages.joined(separator: ", "))"
				
			}
		}
	}
	
}
