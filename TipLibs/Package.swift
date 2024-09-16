// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TipLibs",
		platforms: [.iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TipLibs",
            targets: ["TipLibs"]),
				.library(
						name: "MoxieLib",
						targets: ["MoxieLib"]),
				.library(
					name: "PrivySignIn",
					targets: ["PrivySignIn"]
				)
    ],
		dependencies: [
			.package(url: "https://github.com/privy-io/privy-ios", branch: "main"),
		],
    targets: [
				.target(
						name: "PrivySignIn",
						dependencies: [.product(name: "Privy", package: "privy-ios")]
				),
				.testTarget(
						name: "PrivySignInTests",
						dependencies: ["PrivySignIn"]),
        .target(
            name: "TipLibs"),
				.testTarget(
						name: "TipLibsTests",
						dependencies: ["TipLibs"]),
				.target(
						name: "MoxieLib"),
				.testTarget(
						name: "MoxieTests",
						dependencies: ["MoxieLib"])
    ]
)
