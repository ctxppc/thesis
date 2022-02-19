// Glyco © 2021–2022 Constantino Tsarouhas

import GlycoKit
import Sisp
import XCTest

final class IntermediateProgramsTestCase : XCTestCase {
	
	override class var defaultTestSuite: XCTestSuite {
		
		let suite = XCTestSuite(forTestCaseClass: Self.self)
		
		if let path = ProcessInfo.processInfo.environment["intermediate_test_programs"] {
			let urls = try! FileManager.default.contentsOfDirectory(at: .init(fileURLWithPath: path), includingPropertiesForKeys: nil)
			let urlsByGroup = Dictionary(grouping: urls) { url in
				url.deletingPathExtension().lastPathComponent
			}
			for (group, urls) in urlsByGroup {
				let test = Self(selector: #selector(checkProgram))
				test.group = group
				test.urls = urls
				suite.addTest(test)
			}
		}
		
		return suite
		
	}
	
	/// The group's name.
	var group = ""
	
	/// The program's urls.
	var urls = [URL]()
	
	func checkProgram() throws {
		print("Testing “\(group)” (\(urls.count) programs)…")
		let programSispsByLanguageName = Dictionary(uniqueKeysWithValues: try urls.map { ($0.pathExtension, try String(contentsOf: $0)) })
		try HighestSupportedLanguage.iterate(DecodeSourceAndTestIntermediateProgramsAction(programSispsByLanguageName: programSispsByLanguageName))
	}
	
	struct TestError : Error {
		let groupName: String
		let underlyingError: Error
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
