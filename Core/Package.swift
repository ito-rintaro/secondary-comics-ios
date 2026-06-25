// swift-tools-version: 6.0
import PackageDescription

// SecondaryComicsCore: 純 Swift のドメイン層 + アプリケーション層（ports / use cases）。
// SwiftUI / URLSession に非依存（テスト容易性のため）。
let package = Package(
    name: "SecondaryComicsCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14) // ヘッドレスな `swift test` をホスト Mac 上で実行するため
    ],
    products: [
        .library(name: "SecondaryComicsCore", targets: ["SecondaryComicsCore"])
    ],
    targets: [
        .target(name: "SecondaryComicsCore"),
        .testTarget(
            name: "SecondaryComicsCoreTests",
            dependencies: ["SecondaryComicsCore"]
        )
    ]
)
