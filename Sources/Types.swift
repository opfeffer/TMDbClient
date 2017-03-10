//
//  Types.swift
//  TMDbClient
//
//  Created by Oliver Pfeffer on 3/9/17.
//  Copyright © 2017 Astrio, LLC. All rights reserved.
//

import Foundation

/// JSON aliases for code clarity.

public typealias JSON = Any
public typealias JSONDictionary = [String: JSON]
public typealias JSONArray = [JSONDictionary]

/// Return type of `URLJSONPromise`, tuple of `URLSession` types.
public typealias Transmission = (URLRequest, HTTPURLResponse, JSON?)

/// JSON-friendly key/value parameters.
public typealias Parameters = [String: Any]

/// TMDbClient's expectation of an API route.
protocol TMDbRoute {
    var parameters: Parameters? { get }
    var path: String { get }

    var cachePolicy: URLRequest.CachePolicy? { get }
}

extension TMDbRoute {
    var cachePolicy: URLRequest.CachePolicy? { return nil }
}

/// Generic protocol to be implemented by types that can be directly initialized
/// from TMDb-provided JSON.
protocol JSONInitializing {
    init(json: JSON) throws
}
