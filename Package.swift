// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "mithfor-tg-bot",
    dependencies: [
        .package(url: "https://github.com/rapierorg/telegram-bot-swift", from: "2.1.2"),
        .package(url: "https://github.com/Alamofire/Alamofire", .upToNextMajor(from: "5.9.1"))
    ],
    targets: [
        
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "mithfor-tg-bot",
            dependencies: [
                .product(name: "TelegramBotSDK", package: "telegram-bot-swift"),
                .product(name: "Alamofire", package: "alamofire")]
        )
    ]
)
