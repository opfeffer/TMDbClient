import PackageDescription

let package = Package(
    name: "TMDbClient",
    dependencies: [
        .Target(url: "https://github.com/Alamofire/Alamofire", majorVersion: 4)
        .Target(url: "https://github.com/mxcl/PromiseKit", majorVersion: 4)
        .Target(url: "https://github.com/PromiseKit/Alamofire", majorVersion: 1)
    ]
)

