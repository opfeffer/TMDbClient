import PackageDescription

let package = Package(
    name: "TMDbClient",
    dependencies: [
        .Target(url: "https://github.com/mxcl/PromiseKit", majorVersion: 4)
    ]
)

