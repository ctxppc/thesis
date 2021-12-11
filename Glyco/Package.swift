// swift-tools-version:5.5
// Glyco © 2021 Constantino Tsarouhas

import PackageDescription

let package = Package(
	name:			"Glyco",
	platforms:		[.macOS(.v11)],
	products:		[
		.executable(name: "Glyco", targets: ["Glyco"]),
		.library(name: "GlycoKit", targets: ["GlycoKit"]),
		.library(name: "Sisp", targets: ["Sisp"]),
	],
	dependencies:	[
		.package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
		.package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.1"),
		.package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.0.0")),
		.package(url: "https://github.com/ctxppc/DepthKit.git", .upToNextMinor(from: "0.10.0")),
		.package(url: "https://github.com/ctxppc/PatternKit.git", .upToNextMinor(from: "0.4.0")),
		.package(url: "https://github.com/jpsim/Yams.git", from: "4.0.6"),	// TODO: Remove when no longer needed.
	],
	targets:		[
		
		.executableTarget(name: "Glyco", dependencies: [
			"GlycoKit",
			.product(name: "ArgumentParser", package: "swift-argument-parser"),
		]),
		
		.target(name: "GlycoKit", dependencies: [
			"Sisp", "Yams",
			.product(name: "Collections", package: "swift-collections"),
			.product(name: "DepthKit", package: "DepthKit"),
		]),
		.testTarget(name: "GlycoKitTests", dependencies: ["GlycoKit"]),
		
		.target(name: "Sisp", dependencies: [
			.product(name: "Algorithms", package: "swift-algorithms"),
			.product(name: "Collections", package: "swift-collections"),
			.product(name: "DepthKit", package: "DepthKit"),
			.product(name: "PatternKit", package: "PatternKit"),
		]),
		.testTarget(name: "SispTests", dependencies: ["Sisp"]),
		
	]
)
