import PackageDescription

let package = Package(
    name:         "SwiftChart",
    targets:      [],
    dependencies: [
        .Package(url: "https://github.com/JohnSundell/Files", majorVersion: 2, minor: 0)
    ]
)