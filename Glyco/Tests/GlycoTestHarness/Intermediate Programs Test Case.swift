// Glyco © 2021–2022 Constantino Tsarouhas

import GlycoKit
import Sisp
import XCTest

final class IntermediateProgramsTestCase : XCTestCase {
	
	func testPrograms() throws {
		
		guard
			let urls = try? FileManager.default.contentsOfDirectory(at: .init(fileURLWithPath: "Tests/Test Programs"), includingPropertiesForKeys: nil)
		else { throw XCTSkip("Tests/Test Programs doesn't exist") }
		
		let urlsByGroupName = Dictionary(grouping: urls) { url in
			url.deletingPathExtension().lastPathComponent
		}
		guard !urlsByGroupName.isEmpty else { throw XCTSkip("No candidate programs named <name>.<source-language>") }
		
		var errors = TestErrors()
		for (groupName, urls) in urlsByGroupName {
			do {
				print(">> Testing “\(groupName)”, ", terminator: "")
				var programSispsByLanguageName = Dictionary(uniqueKeysWithValues: try urls.map { ($0.pathExtension, try String(contentsOf: $0)) })
				programSispsByLanguageName.removeValue(forKey: "out")
				print("consisting of \(programSispsByLanguageName.count) intermediate programs… ", terminator: "")
				try HighestSupportedLanguage.iterate(DecodeSourceAndTestIntermediateProgramsAction(programSispsByLanguageName: programSispsByLanguageName))
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
	
	struct TestErrors : Error {
		var errors = [TestError]()
		var isEmpty: Bool { errors.isEmpty }
		mutating func add(_ error: TestError) { errors.append(error) }
	}
	
	struct TestError : Error {
		let groupName: String
		let error: Error
	}
	
}

private struct DecodeSourceAndTestIntermediateProgramsAction : LanguageAction {
	
	let programSispsByLanguageName: [String : String]
	
	func callAsFunction<L : Language>(language: L.Type) throws -> ()? {
		var programSispsByLanguageName = programSispsByLanguageName
		guard let programSisp = programSispsByLanguageName.removeValue(forKey: language.name) else { return nil }
		let sourceProgram = try SispDecoder(from: programSisp).decode(L.Program.self)
		try L.reduce(sourceProgram, using: IntermediateProgramsTestReductor(programSispsByLanguageName: programSispsByLanguageName), configuration: .init(target: .sail))
		return ()
	}
	
}

private struct IntermediateProgramsTestReductor : ProgramReductor {
	
	var programSispsByLanguageName: [String : String]
	
	mutating func update<L : Language>(language: L.Type, program actual: L.Program) throws -> ()? {
		if programSispsByLanguageName.isEmpty {
			return ()
		} else if let expectedProgramSisp = programSispsByLanguageName.removeValue(forKey: language.name) {
			let expected = try L.Program(fromEncoded: expectedProgramSisp)
			XCTAssertEqual(actual, expected)
			return nil
		} else {
			return nil
		}
	}
	
	func result() throws {
		if !programSispsByLanguageName.isEmpty {
			throw Error.unrecognisedLanguages(.init(programSispsByLanguageName.keys))
		}
	}
	
	enum Error : Swift.Error {
		case unrecognisedLanguages(Set<String>)
	}
	
}
