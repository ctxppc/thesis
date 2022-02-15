// Glyco © 2021–2022 Constantino Tsarouhas

import XCTest

final class HarnessTestCase : XCTestCase {
	
	override class var defaultTestSuite: XCTestSuite {
		
		let suite = XCTestSuite(forTestCaseClass: Self.self)
		
		if let path = ProcessInfo.processInfo.environment["HARNESS_BUNDLE"] {
			let urls = try! FileManager.default.contentsOfDirectory(at: .init(fileURLWithPath: path), includingPropertiesForKeys: nil)
			for url in urls {
				let test = Self(selector: #selector(checkProgram))
				test.programURL = url
				suite.addTest(test)
			}
		}
		
		return suite
		
	}
	
	var programURL: URL!
	
	func checkProgram() {
		print("Testing \(programURL.lastPathComponent)…")
		// TODO
	}
	
}
