// Glyco © 2021–2022 Constantino Tsarouhas

import GlycoKit
import Sisp
import XCTest

final class ProgramResultTestCase : XCTestCase {
	
	func testPrograms() throws {
		
		guard let simulatorPath = ProcessInfo.processInfo.environment["simulator"] else { throw XCTSkip("Missing “simulator” environment variable") }
		
		guard let urls = try? FileManager.default.contentsOfDirectory(at: .init(fileURLWithPath: "Tests/Test Programs"), includingPropertiesForKeys: nil)
		else { throw XCTSkip("Tests/Test Programs doesn't exist") }
		
		let urlsByGroupName = Dictionary(grouping: urls) { url in
			url.deletingPathExtension().lastPathComponent
		}
		guard !urlsByGroupName.isEmpty else { throw XCTSkip("No candidate programs named <name>.<source-language>") }
		
		var errors = TestErrors()
		for (groupName, urls) in urlsByGroupName {
			do {
				print(">> Testing “\(groupName)” ", terminator: "")
				var sourceURLsByLanguageName = Dictionary(uniqueKeysWithValues: urls.map { ($0.pathExtension.uppercased(), $0) })
				guard let expectedResultString = try sourceURLsByLanguageName.removeValue(forKey: "OUT").map(String.init(contentsOf:)) else { continue }
				guard let expectedResult = Int(expectedResultString.trimmingCharacters(in: .whitespacesAndNewlines))
				else { throw ProgramResultTestError.invalidExpectedResult(expectedResultString) }
				print("with expected result \(expectedResult)… ", terminator: "")
				try HighestSupportedLanguage.iterate(
					DecodeSourceAndSimulateProgramsAction(
						sourceURLsByLanguageName:	sourceURLsByLanguageName,
						simulatorURL:				.init(fileURLWithPath: simulatorPath),
						expectedResult:				expectedResult
					)
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
	
	struct TestErrors : Error {
		var errors: [TestError] = []
		var isEmpty: Bool { errors.isEmpty }
		mutating func add(_ error: TestError) { errors.append(error) }
	}
	
	struct TestError : Error {
		let groupName: String
		let error: Error
	}
	
}

private struct DecodeSourceAndSimulateProgramsAction : LanguageAction {
	
	let sourceURLsByLanguageName: [String : URL]
	let simulatorURL: URL
	let expectedResult: Int
	
	func callAsFunction<L : Language>(language: L.Type) throws -> ()? {
		
		var sourceURLsByLanguageName = sourceURLsByLanguageName
		guard let sourceURL = sourceURLsByLanguageName.removeValue(forKey: language.name) else { return nil }
		
		let sourceProgram = try SispDecoder(from: .init(contentsOf: sourceURL)).decode(L.Program.self)
		let elfData = try L.elf(from: sourceProgram, configuration: .init(target: .sail))
		
		let tempDirectoryURL = try FileManager.default.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
		defer { try! FileManager.default.removeItem(at: tempDirectoryURL) }
		
		let elfURL = tempDirectoryURL.appendingPathComponent("prog", isDirectory: false)
		try elfData.write(to: elfURL)
		
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
		
		return ()
		
	}
	
}

enum ProgramResultTestError : Error {
	case invalidExpectedResult(String)
}
