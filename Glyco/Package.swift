// swift-tools-version:5.5
// Glyco © 2021–2022 Constantino Tsarouhas

import PackageDescription

let package = Package(
	name:			"Glyco",
	platforms:		[.macOS(.v11)],
	products:		[
		.executable(name: "glyco", targets: ["glyco"]),
		.library(name: "GlycoKit", targets: ["GlycoKit"]),
		.library(name: "Sisp", targets: ["Sisp"]),
	],
	dependencies:	[
		.package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
		.package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.1"),
		.package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.0.0")),
		.package(url: "https://github.com/ctxppc/DepthKit.git", .upToNextMinor(from: "0.10.0")),
		.package(url: "https://github.com/ctxppc/PatternKit.git", .upToNextMinor(from: "0.4.0")),
	],
	targets:		[
		
		.executableTarget(name: "glyco", dependencies: [
			"GlycoKit",
			.product(name: "ArgumentParser", package: "swift-argument-parser"),
		]),
		
		.target(name: "GlycoKit", dependencies: [
			"Sisp",
			.product(name: "Collections", package: "swift-collections"),
			.product(name: "DepthKit", package: "DepthKit"),
		]),
		.testTarget(name: "GlycoKitTests", dependencies: ["GlycoKit"]),
		
		.testTarget(name: "GlycoTestHarness", dependencies: ["GlycoKit"]),
		
		.target(name: "Sisp", dependencies: [
			.product(name: "Algorithms", package: "swift-algorithms"),
			.product(name: "Collections", package: "swift-collections"),
			.product(name: "DepthKit", package: "DepthKit"),
			.product(name: "PatternKit", package: "PatternKit"),
		]),
		.testTarget(name: "SispTests", dependencies: ["Sisp"]),
		
	]
)

#if os(macOS)
	package.dependencies.append(.package(url: "https://github.com/ctxppc/KZFileWatchers.git", from: "1.1.1"))
	package.targets[0].dependencies.append(.product(name: "KZFileWatchers", package: "KZFileWatchers"))
#endif
