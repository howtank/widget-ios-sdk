// swift-tools-version:5.3
import PackageDescription
let package = Package(
    name: "HowtankWidgetSwift",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "HowtankWidgetSwift", 
            targets: ["HowtankWidgetSwift"])
    ],
    targets: [
        .binaryTarget(
            name: "HowtankWidgetSwift", 
            path: "HowtankWidgetSwift.xcframework")
    ])
