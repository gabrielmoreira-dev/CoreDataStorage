// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "CoreDataStorage",
    products: [
        .library(
            name: "CoreDataStorage",
            targets: ["CoreDataStorage"]
        ),
        .library(
            name: "CoreDataStorageTestUtils",
            targets: ["CoreDataStorageTestUtils"]
        )
    ],
    targets: [
        .target(
            name: "CoreDataStorage"
        ),
        .target(
            name: "CoreDataStorageTestUtils",
            dependencies: ["CoreDataStorage"],
            path: "Sources/TestUtils"
        ),
        .testTarget(
            name: "CoreDataStorageTests",
            dependencies: ["CoreDataStorage", "CoreDataStorageTestUtils"]
        )
    ]
)
