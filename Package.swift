// swift-tools-version:5.5
// Glyco © 2021 Constantino Tsarouhas

import PackageDescription

let package = Package(
	name: "Glyco",
	products: [
		.library(name: "Glyco", targets: ["Glyco"]),
	],
	dependencies: [
		.package(url: "https://github.com/ctxppc/DepthKit.git", .upToNextMinor(from: "0.10.0")),
	],
	targets: [
		.target(name: "Glyco", dependencies: ["DepthKit"]),
		.testTarget(name: "GlycoTests", dependencies: ["Glyco"]),
	]
)
