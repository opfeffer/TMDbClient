//: TMDbClient Playground - interact with themoviedb.org API in real-time

import TMDbClient
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true


TMDbClient.initialize(with: "123").then {
    print("success")
}