// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Camera",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Camera",
            targets: ["Camera"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/pxlshpr/SwiftHaptics", from: "0.1.3"),
        .package(url: "https://github.com/pxlshpr/SwiftUISugar", from: "0.0.320"),
        .package(url: "https://github.com/pxlshpr/VisionSugar", from: "0.0.75"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Camera",
            dependencies: [
                .product(name: "SwiftHaptics", package: "swifthaptics"),
                .product(name: "SwiftUISugar", package: "swiftuisugar"),
                .product(name: "VisionSugar", package: "visionsugar"),
            ]),
        .testTarget(
            name: "CameraTests",
            dependencies: ["Camera"]),
    ]
)
