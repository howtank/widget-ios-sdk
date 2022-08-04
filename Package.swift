// swift-tools-version:5.3
import PackageDescription
let package = Package(
    name: "HowtankWidgetSwift",
    exclude: ["source/", "package.json", "publish_podspec.sh", "update_version.sh"]
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
