// Glyco © 2021–2022 Constantino Tsarouhas

import GlycoKit
import XCTest

final class ProgramResultTestCase : XCTestCase {
	
	override class var defaultTestSuite: XCTestSuite {
		
		let suite = XCTestSuite(forTestCaseClass: Self.self)
		
		if let programPath = ProcessInfo.processInfo.environment["execution_test_programs"],
		   let simulatorPath = ProcessInfo.processInfo.environment["simulator"] {
			let urls = try! FileManager.default.contentsOfDirectory(at: .init(fileURLWithPath: programPath), includingPropertiesForKeys: nil)
			for url in urls {
				let test = Self(selector: #selector(verifyProgram))
				test.simulatorURL = .init(fileURLWithPath: simulatorPath)
				test.programURL = url
				test.expectedResult = Int(url.deletingPathExtension().pathExtension)!
				suite.addTest(test)
			}
		}
		
		return suite
		
	}
	
	var simulatorURL: URL!
	var programURL: URL!
	var expectedResult = 0
	
	func verifyProgram() throws {
		
		let elf = try HighestSupportedLanguage.elfFromProgram(
			fromSispString:	.init(contentsOf: programURL),
			sourceLanguage:	programURL.pathExtension,
			configuration:	.init(target: .sail)
		)
		
		let tempDirectoryURL = try FileManager.default.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
		defer { try! FileManager.default.removeItem(at: tempDirectoryURL) }
		
		let elfURL = tempDirectoryURL.appendingPathComponent("prog", isDirectory: false)
		try elf.write(to: elfURL)
		
		let outputURL = tempDirectoryURL.appendingPathComponent("execution", isDirectory: false)
		let outputHandle = try FileHandle(forWritingTo: outputURL)
		
		let sim = Process()
		sim.executableURL = simulatorURL
		sim.arguments = [elfURL.path]
		sim.standardOutput = outputHandle
		try sim.run()
		sim.waitUntilExit()
		
		let output = try String(contentsOf: outputURL)
		XCTAssert(output.contains("\(expectedResult)"), "Simulator output doesn't contain expected result \(expectedResult)")	// TODO: Match string
		
	}
	
}
