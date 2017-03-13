//
//  TMDbClient.swift
//  TMDbClient
//
//  Created by Oliver Pfeffer on 12/7/16.
//  Copyright © 2016 Astrio, LLC. All rights reserved.
//

import Foundation
import PromiseKit

/// Provides networking capabilities to interact with TMDb's APIs.
///
/// - Note: Make sure you initialize the library by providing your personal *TMDb API Key* via `initialize(with:)`
public class TMDbClient {

    /// TMDb base API domain.
    public private(set) static var baseUrl = URL(string: "https://api.themoviedb.org/3")!

    /// User-provided API Key; set via `initialize(with:)`
    public private(set) static var apiKey: ApiKey = ""

    /// Flag controlling HTTP request/response logging in the console.
    public private(set) static var logs: Bool = false

    /// Underlying URLSession object; currently not publicly exposed.
    private(set) static var session: URLSession = {
        let configuration = URLSessionConfiguration.default

        let bundle = Bundle(for: TMDbClient.self)
        let path = bundle.bundleIdentifier ?? String(describing: TMDbClient.self)
        configuration.urlCache = URLCache(memoryCapacity: 5 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: path)

        return URLSession(configuration: configuration)
    }()

    /// Initializes the client with your TMDb-provided API key.
    ///
    /// - note: call in application(_:didFinishLaunchingWithOptions:)
    public class func initialize(with apiKey: ApiKey, logs: Bool = false) -> Promise<Void> {
        self.logs = logs

        self.apiKey = apiKey
        self.configuration = getObject(Router.configuration).catch { _ in }

        return configuration.asVoid()
    }

    /// Promise holding TMDb's system wide configuration information.
    ///
    /// Since some elements of the API require some knowledge of this configuration data, calling `initialize(with:)` will
    /// fetch the latest `Configuration` from TMDb and chain all later requests to this promise.
    static public private(set) var configuration: Promise<Configuration> = Promise(error: Error.uninitialized).catch { _ in }

    // MARK: Internal/Private methods

    /// Fetches JSON and attempts to initialize object adhering to `JSONInitializing`.
    class func getObject<T: JSONInitializing>(_ route: TMDbRoute) -> Promise<T> {
        return get(route).then(on: .global()) { (_, _, json) -> T in
            guard let json = json else { throw URLSessionError.noJSONPayload }

            return try T(json: json)
        }
    }

    /// Returns `Transmission` data for a given TMDbRoute.
    class func get(_ route: TMDbRoute) -> URLJSONPromise {
        do {
            let rq = try urlRequest(for: route)
            return session.jsonTask(with: rq).log()
        } catch {
            return URLJSONPromise(error: error)
        }
    }

    /// Turns a given TMDbRoute into a URLSession-friendly `URLRequest` object.
    private class func urlRequest(for route: TMDbRoute) throws -> URLRequest {
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

    /// TMDb's API Key's are String-based.
    public typealias ApiKey = String

    /// Global TMDbClient error domain.
    public enum Error: Swift.Error {
        /// Don't forget to call `initialize(with:)`
        case uninitialized

        /// Indicates a given TMBdRoute is a malformed URL.
        case badUrl
    }

    /// System wide routes; not namespace-specific.
    enum Router: TMDbRoute {
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

    /// Captures Request/Response information on a given `URLSession` `URLDataTask`; controlled via `TMDbClient.logs` flag.
    func log() -> URLJSONPromise {
        guard TMDbClient.logs == true else { return self }

        let date = Date()
        return always {
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
