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
        .package(url: "https://github.com/pxlshpr/SwiftHaptics", from: "0.1.4"),
        .package(url: "https://github.com/pxlshpr/SwiftSugar", from: "0.0.97"),
        .package(url: "https://github.com/pxlshpr/VisionSugar", from: "0.0.80"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Camera",
            dependencies: [
                .product(name: "SwiftHaptics", package: "SwiftHaptics"),
                .product(name: "SwiftSugar", package: "SwiftSugar"),
                .product(name: "VisionSugar", package: "VisionSugar"),
            ]),
        .testTarget(
            name: "CameraTests",
            dependencies: ["Camera"]),
    ]
)
