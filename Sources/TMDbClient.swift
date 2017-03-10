//
//  TMDbClient.swift
//  TMDbClient
//
//  Created by Oliver Pfeffer on 12/7/16.
//  Copyright © 2016 Astrio, LLC. All rights reserved.
//

import Foundation
import PromiseKit


public class TMDbClient {

    public private(set) static var baseUrl = URL(string: "https://api.themoviedb.org/3")!
    public private(set) static var apiKey: ApiKey = ""

    public private(set) static var logs: Bool = false

    private(set) static var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = URLCache(memoryCapacity: 5 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: "com.opfeffer.TMDbClient")

        return URLSession(configuration: configuration)
    }()

    /// Initializes the client with your TMDb-provided access token.
    ///
    /// - note: call in application(_:didFinishLaunchingWithOptions:)
    public class func initialize(with apiKey: ApiKey, logs: Bool = false) -> Promise<Void> {
        self.logs = logs

        self.apiKey = apiKey
        self.configuration = fetchConfiguration().catch { _ in }

        return configuration.asVoid()
    }

    static public private(set) var configuration: Promise<Configuration> = Promise(error: Error.uninitialized).catch { _ in }

    // MARK: API Requests

    class func fetchConfiguration() -> Promise<Configuration> {
        return get(Router.configuration).asDictionary().then { json -> Configuration in
            return try Configuration(json: json)
        }

    }

    // MARK: Internal/Private methods

    class func getObject<T: JSONInitializing>(_ route: TMDBRoute) -> Promise<T> {
        return get(route).then { (_, _, json) -> T in
            guard let json = json else { throw URLSessionError.noJSONPayload }

            return try T(json: json)
        }
    }

    class func get(_ route: TMDBRoute) -> URLJSONPromise {
        do {
            let rq = try urlRequest(for: route)
            return session.jsonTask(with: rq).log()
        } catch {
            return URLJSONPromise(error: error)
        }
    }

    private class func urlRequest(for route: TMDBRoute) throws -> URLRequest {
        let url = baseUrl.appendingPathComponent(route.path)
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { throw Error.badUrl }

        let queryItems = route.parameters?.map { URLQueryItem(name: $0.key, value: String(describing: $0.value)) } ?? []
        let key = URLQueryItem(name: "api_key", value: apiKey)
        components.queryItems = queryItems + [key]

        let policy = route.cachePolicy ?? .useProtocolCachePolicy
        return URLRequest(url: components.url!, cachePolicy: policy)
    }

}

// MARK: - Nested Types

extension TMDbClient {

    public typealias ApiKey = String

    public enum Error: Swift.Error {
        /// Don't forget to call `initialize(with:)`
        case uninitialized

        case badUrl
    }

    enum Router: TMDBRoute {
        case configuration

        var path: String {
            switch self {
            case .configuration:
                return "/configuration"
            }
        }

        var parameters: Parameters? {
            return nil
        }

        var cachePolicy: URLRequest.CachePolicy? {
            switch self {
            case .configuration:
                return .returnCacheDataElseLoad
            }
        }
    }

}

// MARK: - URLJSONPromise Logger

private extension URLJSONPromise {
    func log() -> URLJSONPromise {
        guard TMDbClient.logs == true else { return self }

        let date = Date()
        return always(on: .global()) {
            print("\n")
            print("Request:", self.urlRequest?.debugDescription ?? "<unavailable> (represents bug!)")

            var response: HTTPURLResponse?, json: JSON?
            if let (_, rsp, j) = self.value {
                response = rsp
                json = j
            } else if let e = self.error, case URLSessionError.badResponse(let rsp, _, let j) = e {
                response = rsp
                json = j
            } else {
                print("URLJSONPromise threw unexpected error=", self.error ?? "nil")
            }

            let statusCode = response?.statusCode ?? -1
            let time = String(format: "%.2f seconds", -date.timeIntervalSinceNow)

            print("Response: HTTP Status=\(statusCode), Time=\(time)")
            print("Payload: \(json ?? "nil")")
        } as! URLJSONPromise
    }
}
