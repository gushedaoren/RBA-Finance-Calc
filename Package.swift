// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "RBA-Finance-Calc",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "RBACalc",
            targets: ["RBACalc"]
        ),
    ],
    targets: [
        .target(
            name: "RBACalc",
            path: "Sources/RBACalc"
        ),
        .testTarget(
            name: "RBACalcTests",
            dependencies: ["RBACalc"],
            path: "Tests/RBACalcTests"
        ),
    ]
)
