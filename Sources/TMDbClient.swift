//
//  TMDbClient.swift
//  TMDbClient
//
//  Created by Oliver Pfeffer on 12/7/16.
//  Copyright © 2016 Astrio, LLC. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import PMKAlamofire

public class TMDbClient {

    public enum Error: Swift.Error {
        /// Don't forget to call `initialize(with:)`
        case uninitialized

        case badUrl
    }

    public private(set) static var token: Token = "" {
        didSet {
            sessionManager.adapter = TokenManager(token: token)
        }
    }

    static var sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = URLCache(memoryCapacity: 5 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: "com.opfeffer.TMDbClient")

        return SessionManager(configuration: configuration)
    }()

    /// Initializes the client with your TMDb-provided access token.
    ///
    /// - note: call in application(_:didFinishLaunchingWithOptions:)
    public class func initialize(with token: Token) -> Promise<Void> {
        self.token = token
        self.configuration = fetchConfiguration()

        return configuration.asVoid().catch { _ in }
    }

    static var configuration: Promise<Configuration> = Promise(error: Error.uninitialized)

    // MARK: API Requests

    class func fetchConfiguration() -> Promise<Configuration> {
        return sessionManager.request(Router.configuration)
            .validate()
            .responseJSON().then(on: .global()) { json -> Configuration in
                print(json)
                return try Configuration(json: json)
        }
    }

}

// MARK: - Nested Types

extension TMDbClient {

    public typealias Token = String

    struct TokenManager: RequestAdapter {
        let token: Token

        func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
            guard let url = urlRequest.url, var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { throw TMDbClient.Error.badUrl }
            let apiKey = URLQueryItem(name: "api_key", value: token)

            let queryItems = components.queryItems ?? []
            components.queryItems = queryItems + [apiKey]

            var urlRequest = urlRequest
            urlRequest.url = try components.asURL()
            
            return urlRequest
        }
    }


    enum Router: URLRequestConvertible {
        static let baseUrl = URL(string: "https://api.themoviedb.org/3")!

        case configuration

        var path: String {
            return "/configuration"
        }

        var parameters: Parameters? {
            return nil
        }

        func asURLRequest() throws -> URLRequest {
            let url = Router.baseUrl.appendingPathComponent(path)
            let urlRequest = URLRequest(url: url)

            return try URLEncoding.default.encode(urlRequest, with: parameters)
        }
        
    }

}
