// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Web3WalletSDK",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "Web3WalletSDK",
            targets: ["Web3WalletSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/web3swift-team/web3swift.git", from: "3.1.0"),
    ],
    targets: [
        .target(
            name: "Web3WalletSDK",
            dependencies: [
                .product(name: "web3swift", package: "web3swift")
            ]),
        .testTarget(
            name: "Web3WalletSDKTests",
            dependencies: ["Web3WalletSDK"]),
    ]
)
