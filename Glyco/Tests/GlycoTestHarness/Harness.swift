// Glyco © 2021–2022 Constantino Tsarouhas

import GlycoKit
import XCTest

final class HarnessTestCase : XCTestCase {
	
	override class var defaultTestSuite: XCTestSuite {
		
		let suite = XCTestSuite(forTestCaseClass: Self.self)
		
		if let path = ProcessInfo.processInfo.environment["HARNESS_BUNDLE"] {
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
		
		print("Testing \(group)…")
		
		let urlsByLanguageName = Dictionary(uniqueKeysWithValues: urls.map { ($0.pathExtension.uppercased(), $0) })
		
		let sourceLanguageName = HighestSupportedLanguage.nameOfHighestLanguage(inUppercasedNameSet: urlsByLanguageName.keys)
		let actualSispsByLanguageName = try HighestSupportedLanguage.loweredProgramRepresentations(
			fromSispString:		.init(contentsOf: urlsByLanguageName[sourceLanguageName]!),
			sourceLanguage:		sourceLanguageName,
			targetLanguages:	nil,
			configuration:		.init(target: .sail)
		)
		
		// TODO
		
	}
	
	struct TestError : Error {
		let groupName: String
		let underlyingError: Error
	}
	
}

private extension Language {
	static func nameOfHighestLanguage<V>(inUppercasedNameSet languageNames: Dictionary<String, V>.Keys) -> String {
		languageNames.contains("\(Self.self)") ? "\(Self.self)" : Lower.nameOfHighestLanguage(inUppercasedNameSet: languageNames)
	}
}
