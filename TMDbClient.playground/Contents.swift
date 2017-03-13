//: TMDbClient Playground - interact with themoviedb.org API in real-time

import TMDbClient
import PromiseKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

/// Simple `Promise` extension to finish playground execution as soon as the promise resolves.
extension Promise {
    func finishPlaygroundExecution() {
        always { PlaygroundPage.current.finishExecution() }.catch { _ in }
    }
}


//: TMDbClient initialization

TMDbClient.initialize(with: "b427bda9569b7902569fb64df79d3ed8", logs: true)


//: Movie namespace

 TMDbClient.Movies.details(movieId: 171372, appends: [.credits]).then { print($0) }.finishPlaygroundExecution()
//TMDbClient.Movies.credits(movieId: 171372).then { print($0) }.finishPlaygroundExecution()

//: People namespace

//TMDbClient.People.details(personId: 123, appends: [.externalIds]).finishPlaygroundExecution()
