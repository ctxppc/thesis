// Glyco © 2021–2022 Constantino Tsarouhas

import GlycoKit
import XCTest

final class ProgramResultTestCase : XCTestCase {
	
	func testPrograms() throws {
		
		guard let simulatorPath = ProcessInfo.processInfo.environment["simulator"] else { throw XCTSkip("Missing “simulator” environment variable") }
		
		let sourceURLs = try FileManager.default.contentsOfDirectory(at: .init(fileURLWithPath: "."), includingPropertiesForKeys: nil)
		let sourceURLExpectedResultPairs = sourceURLs.compactMap { sourceURL in
			Int(sourceURL.deletingPathExtension().pathExtension).map { (sourceURL, $0 ) }
		}
		guard !sourceURLExpectedResultPairs.isEmpty else { throw XCTSkip("No candidate programs named <name>.<expected-value>.<source-language>") }
		
		var errors = [TestError]()
		for (sourceURL, expectedResult) in sourceURLExpectedResultPairs {
			do {
				
				print(">> Testing “\(sourceURL.lastPathComponent)” in the simulator… ", terminator: "")
				let elf = try HighestSupportedLanguage.elfFromProgram(
					fromSispString:	.init(contentsOf: sourceURL),
					sourceLanguage:	sourceURL.pathExtension,
					configuration:	.init(target: .sail)
				)
				
				let tempDirectoryURL = try FileManager.default.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
				defer { try! FileManager.default.removeItem(at: tempDirectoryURL) }
				
				let elfURL = tempDirectoryURL.appendingPathComponent("prog", isDirectory: false)
				try elf.write(to: elfURL)
				
				let outputURL = tempDirectoryURL.appendingPathComponent("execution", isDirectory: false)
				let outputHandle = try FileHandle(forWritingTo: outputURL)
				
				let sim = Process()
				sim.executableURL = .init(fileURLWithPath: simulatorPath)
				sim.arguments = [elfURL.path]
				sim.standardOutput = outputHandle
				try sim.run()
				sim.waitUntilExit()
				
				let output = try String(contentsOf: outputURL)
				XCTAssert(output.contains("\(expectedResult)"), "Simulator output doesn't contain expected result \(expectedResult)")	// TODO: Match string
				
			} catch {
				errors.append(.init(sourceURL: sourceURL, error: error))
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
		let sourceURL: URL
		let error: Error
	}
	
}
