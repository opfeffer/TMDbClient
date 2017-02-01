//: TMDbClient Playground - interact with themoviedb.org API in real-time

import TMDbClient
import PromiseKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

extension Promise {
    func finishPlaygroundExecution() {
        self.always { PlaygroundPage.current.finishExecution() }
    }
}

TMDbClient.initialize(with: "b427bda9569b7902569fb64df79d3ed8").then {
    print("success")
}.catch { error in
    print("error", error)
}
