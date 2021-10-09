// swift-tools-version:5.5
// Glyco © 2021 Constantino Tsarouhas

import PackageDescription

let package = Package(
	name: "Glyco",
	products: [
		.executable(name: "Glyco", targets: ["Glyco"]),
		.library(name: "GlycoKit", targets: ["GlycoKit"]),
	],
	dependencies: [
		.package(url: "https://github.com/ctxppc/DepthKit.git", .upToNextMinor(from: "0.10.0")),
	],
	targets: [
		.executableTarget(name: "Glyco", dependencies: [
			"GlycoKit",
			.product(name: "DepthKit", package: "DepthKit"),
		]),
		.target(name: "GlycoKit", dependencies: [
			.product(name: "DepthKit", package: "DepthKit"),
		]),
		.testTarget(name: "GlycoKitTests", dependencies: [
			"GlycoKit",
			.product(name: "DepthKit", package: "DepthKit"),
		]),
	]
)
