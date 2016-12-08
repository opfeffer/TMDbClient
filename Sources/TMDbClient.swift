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

public typealias Token = String

public enum TCError: Error {
    /// Don't forget to call `initialize(with:)`?
    case uninitialized

    case badUrl
}


struct TokenManager : RequestAdapter {
    let token: Token

    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        guard let url = urlRequest.url else { throw TCError.badUrl }
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { throw TCError.badUrl }

        let apiKey = URLQueryItem(name: "api_key", value: token)
        var queryItems = components.queryItems ?? []
        queryItems.append(apiKey)
        components.queryItems = queryItems

        var urlRequest = urlRequest
        urlRequest.url = try components.asURL()

        return urlRequest
    }
}

enum Router : URLRequestConvertible {
    static let baseUrlString = "https://api.themoviedb.org/3"

    case configuration


    func asURLRequest() throws -> URLRequest {
        let result: (path: String, parameters: Parameters) = {
            return ("/configuration", [:])
        }()

        let url = try Router.baseUrlString.asURL()
        let urlRequest = URLRequest(url: url.appendingPathComponent(result.path))

        return try URLEncoding.default.encode(urlRequest, with: result.parameters)
    }

}

public class TMDbClient {

    public private(set) static var token: Token = "" {
        didSet {
            sessionManager.adapter = TokenManager(token: token)
        }
    }

    static var sessionManager: SessionManager = SessionManager.default

    /// Initializes the client with your TMDb-provided access token.
    ///
    /// - note: call in application(_:didFinishLaunchingWithOptions:)
    public class func initialize(with token: Token) -> Promise<Void> {
        self.token = token
        self.configuration = fetchConfiguration()

        return configuration.asVoid().catch { _ in }
    }

    static var configuration: Promise<Configuration> = Promise(error: TCError.uninitialized)

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
