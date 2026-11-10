// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LetterInvadersCore",
    platforms: [.macOS(.v13)],
    products: [.library(name: "LetterInvadersCore", targets: ["LetterInvadersCore"])],
    targets: [
        .target(name: "LetterInvadersCore", path: "LetterInvaders/Core"),
        .testTarget(name: "LetterInvadersCoreTests", dependencies: ["LetterInvadersCore"], path: "Tests")
    ]
)
