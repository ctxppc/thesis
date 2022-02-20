// Glyco © 2021–2022 Constantino Tsarouhas

import GlycoKit
import Sisp
import XCTest

final class IntermediateProgramsTestCase : XCTestCase {
	
	func testProgram() throws {
		
		let urls = try! FileManager.default.contentsOfDirectory(at: .init(fileURLWithPath: "."), includingPropertiesForKeys: nil)
		let urlsByGroupName = Dictionary(grouping: urls) { url in
			url.deletingPathExtension().lastPathComponent
		}
		
		var errors = [TestError]()
		for (groupName, urls) in urlsByGroupName {
			do {
				print(">> Testing “\(groupName)”, consisting of \(urls.count) intermediate programs… ", terminator: "")
				let programSispsByLanguageName = Dictionary(uniqueKeysWithValues: try urls.map { ($0.pathExtension, try String(contentsOf: $0)) })
				try HighestSupportedLanguage.iterate(DecodeSourceAndTestIntermediateProgramsAction(programSispsByLanguageName: programSispsByLanguageName))
				print("OK")
			} catch {
				print("failed")
				errors.append(.init(groupName: groupName, error: error))
			}
		}
		
		if !errors.isEmpty {
			throw TestErrors(errors: errors)
		}
		
	}
	
	struct TestErrors : Error {
		let errors: [TestError]
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
