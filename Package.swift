// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NamePicker",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "NamePicker",
            targets: ["NamePicker"]),
    ],
    dependencies: [
        .package(url: "https://github.com/globulus/swiftui-flow-layout", exact: "1.0.5"),
        .package(url: "https://github.com/pxlshpr/swiftuisugar", from: "0.0.169"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "NamePicker",
            dependencies: [
                .product(name: "SwiftUIFlowLayout", package: "swiftui-flow-layout"),
                .product(name: "SwiftUISugar", package: "swiftuisugar"),
            ]),
        .testTarget(
            name: "NamePickerTests",
            dependencies: ["NamePicker"]),
    ]
)
