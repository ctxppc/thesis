// Glyco © 2021 Constantino Tsarouhas

import ArgumentParser
import DepthKit
import Foundation
import GlycoKit
import Yams

@main
struct CompileCommand : ParsableCommand {
	
	// See protocol.
	static let configuration = CommandConfiguration(commandName: "Glyco", abstract: "Compiles Gly source files to CHERI-RISC-V executables.")
	
	@Option(name: .shortAndLong, help: "The path to a CHERI-RISC-V toolchain, as built by cheribuild. Omit to use ~/cheri.")
	var toolchain: String?
	
	@Option(name: .shortAndLong, help: "The path to a CheriBSD system root, as built by cheribuild. Omit to use output/rootfs-riscv64-purecap within the toolchain.")
	var system: String?
	
	@Argument(help: "The path or filename to a Gly file.")
	var source: String
	
	@Option(name: .shortAndLong, help: "The path of the generated ELF file (will be overwritten). Omit for a dry run.")
	var output: String?
	
	/// Executes the command.
	mutating func run() throws {
		
		let toolchainURL = toolchain.map(URL.init(fileURLWithPath:))
			?? FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("cheri", isDirectory: true)
		let systemURL = system.map(URL.init(fileURLWithPath:))
			?? toolchainURL.appendingPathComponent("output").appendingPathComponent("rootfs-riscv64-purecap", isDirectory: true)
		let configuration = CompilationConfiguration(target: .cheriBSD, toolchainURL: toolchainURL, systemURL: systemURL)
		let sourceData = try Data(contentsOf: URL(fileURLWithPath: source))
		let outputURL = output.map(URL.init(fileURLWithPath:))
		
		let program = try YAMLDecoder().decode(AL.Program.self, from: sourceData)
		let elf = try program.elf(configuration: configuration)
		
		if let outputURL = outputURL {
			try elf.write(to: outputURL)
			print("Exported ELF (\(elf.count) bytes) to \(outputURL.absoluteString).")
		} else {
			print("ELF is \(elf.count) bytes long. Re-run this command with the -o <file> option to save the ELF to disk.")
		}
		
	}
	
}
