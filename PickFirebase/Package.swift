// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PickFirebase",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PickFirebase",
            targets: ["PickFirebase"]),
    ],
    dependencies: [
//        .package(
//            name: "Firebase",
//            url: "https://github.com/akaffenberger/firebase-ios-sdk-xcframeworks.git",
//            .exact("10.22.0")
//        ),
        .package(url: "https://github.com/akaffenberger/firebase-ios-sdk-xcframeworks.git", exact: Version(stringLiteral: "10.22.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PickFirebase",
            dependencies: [
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk-xcframeworks")
            ]
        ),
        
        .testTarget(
            name: "PickFirebaseTests",
            dependencies: ["PickFirebase"]),
    ]
)
