// Glyco © 2021–2022 Constantino Tsarouhas

import DepthKit
import GlycoKit
import Sisp
import XCTest

final class ProgramResultTestCase : XCTestCase {
	
	func testPrograms() throws {
		guard let simulatorPath = ProcessInfo.processInfo.environment["simulator"] else { throw XCTSkip("Missing “simulator” environment variable") }
		for target in CompilationConfiguration.Target.allCases {
			for convention in CompilationConfiguration.CallingConvention.allCases {
				try verifyPrograms(
					programsURL:	.init(fileURLWithPath: "Tests/Test Programs/\(convention).\(target)"),
					simulatorURL:	.init(fileURLWithPath: simulatorPath),
					configuration:	.init(target: target, callingConvention: convention)
				)
			}
		}
	}
	
	func verifyPrograms(programsURL: URL, simulatorURL: URL, configuration: CompilationConfiguration) throws {
		
		guard let urls = try? FileManager.default.contentsOfDirectory(at: programsURL, includingPropertiesForKeys: nil) else { return }
		let urlsByGroupName = Dictionary(grouping: urls) { $0.deletingPathExtension().lastPathComponent }
		var errors = TestErrors(configuration: configuration)
		
		print("> Running test programs using \(simulatorURL.path) for \(configuration)")
		for (groupName, urls) in urlsByGroupName where !groupName.starts(with: ".") {
			do {
				
				var sourceURLsByLanguageName = Dictionary(
					uniqueKeysWithValues: urls.filter { !$0.pathExtension.isEmpty }.map { ($0.pathExtension.uppercased(), $0) }
				)
				guard let expectedResultURL = sourceURLsByLanguageName.removeValue(forKey: "OUT") else { continue }
				
				print(">> Simulating “\(groupName)” ", terminator: "")
				let expectedResultString = try String(contentsOf: expectedResultURL)
				guard let expectedResult = Int(expectedResultString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
					throw ProgramResultTestError.invalidExpectedResult(expectedResultString)
				}
				print("with expected result \(expectedResult)… ", terminator: "")
				try HighestSupportedLanguage.iterate(
					DecodeSourceAndSimulateProgramsAction(
						sourceURLsByLanguageName:	sourceURLsByLanguageName,
						simulatorURL:				simulatorURL,
						expectedResult:				expectedResult,
						configuration:				configuration
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
	
}

private struct DecodeSourceAndSimulateProgramsAction : LanguageAction {
	
	let sourceURLsByLanguageName: [String : URL]
	let simulatorURL: URL
	let expectedResult: Int
	let configuration: CompilationConfiguration
	
	func callAsFunction<L : Language>(language: L.Type) throws -> ()? {
		
		var sourceURLsByLanguageName = sourceURLsByLanguageName
		guard let sourceURL = sourceURLsByLanguageName.removeValue(forKey: language.name) else { return nil }
		
		let sourceProgram = try SispDecoder(from: .init(contentsOf: sourceURL)).decode(L.Program.self)
		let elfData = try L.elf(from: sourceProgram, configuration: configuration)
		
		let tempDirectoryURL = try FileManager.default.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: configuration.toolchainURL, create: true)
		defer { try! FileManager.default.removeItem(at: tempDirectoryURL) }
		
		let elfURL = tempDirectoryURL.appendingPathComponent("prog", isDirectory: false)
		try elfData.write(to: elfURL)
		
		let outputURL = tempDirectoryURL.appendingPathComponent("execution", isDirectory: false)
		try Data().write(to: outputURL)
		let outputHandle = try FileHandle(forWritingTo: outputURL)
		
		let sim = Process()
		sim.executableURL = simulatorURL
		sim.arguments = [elfURL.path]
		sim.standardOutput = outputHandle
		try sim.run()
		sim.waitUntilExit()
		
		let output = try String(contentsOf: outputURL)
		var actualResult: Int?
		var parsingError: Error?
		output.enumerateSubstrings(in: output.startIndex..., options: [.byLines, .reverse]) { substring, _, _, stop in
			
			let substring = substring !! "Expected substring"
			guard substring.hasPrefix("x10 <-") else { return }
			stop = true
			
			do {
				
				let components = substring.components(separatedBy: .init(charactersIn: " :"))
				guard let offsetKeyIndex = components.firstIndex(of: "offset") else { throw ProgramResultTestError.noOffsetKey }
				var offsetValueString = components[offsetKeyIndex + 1]
				
				guard offsetValueString.hasPrefix("0x") else { throw ProgramResultTestError.unprefixedOffsetValueString(offsetValueString) }
				offsetValueString.removeFirst(2)
				
				guard let offsetValue = Int(offsetValueString, radix: 16) else { throw ProgramResultTestError.nonnumericOffsetValueString(offsetValueString) }
				actualResult = offsetValue
				
			} catch {
				parsingError = error
			}
			
		}
		
		if let parsingError = parsingError {
			throw parsingError
		}
		
		XCTAssertEqual(actualResult, expectedResult)
		
		return ()
		
	}
	
}

enum ProgramResultTestError : Error {
	case noOffsetKey
	case unprefixedOffsetValueString(String)
	case nonnumericOffsetValueString(String)
	case invalidExpectedResult(String)
}
