// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TipLibs",
		platforms: [.iOS(.v17),
								.watchOS(.v10)],
    products: [
        .library(
            name: "TipLibs",
            targets: ["TipLibs"]),
				.library(
						name: "MoxitoLib",
						targets: ["MoxitoLib"]),
				.library(
						name: "MoxieLib",
						targets: ["MoxieLib"])
    ],
		dependencies: [
		],
		targets: [
        .target(
            name: "TipLibs"),
				.testTarget(
						name: "TipLibsTests",
						dependencies: ["TipLibs"]),
				.target(
						name: "MoxitoLib"),
				.testTarget(
						name: "MoxitoLibTests",
						dependencies: ["MoxitoLib"]),
				.target(
						name: "MoxieLib",
						dependencies: ["MoxitoLib"]),
				.testTarget(
						name: "MoxieTests",
						dependencies: ["MoxieLib"])
    ]
)
