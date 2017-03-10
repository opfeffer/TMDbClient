//: TMDbClient Playground - interact with themoviedb.org API in real-time

import TMDbClient
import PromiseKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

extension Promise {
    func finishPlaygroundExecution() {
        always { PlaygroundPage.current.finishExecution() }.catch { _ in }
    }
}

TMDbClient.initialize(with: "b427bda9569b7902569fb64df79d3ed8", logs: true)
TMDbClient.Movies.details(movieId: 123).finishPlaygroundExecution()
