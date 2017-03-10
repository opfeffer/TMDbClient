//
//  Types.swift
//  TMDbClient
//
//  Created by Oliver Pfeffer on 3/9/17.
//  Copyright © 2017 Astrio, LLC. All rights reserved.
//

import Foundation

public typealias JSON = Any
public typealias JSONDictionary = [String: JSON]
public typealias JSONArray = [JSONDictionary]

public typealias Transmission = (URLRequest, HTTPURLResponse, JSON?)

public typealias Parameters = [String: Any]

protocol TMDBRoute {
    var parameters: Parameters? { get }
    var path: String { get }

    var cachePolicy: URLRequest.CachePolicy? { get }
}

extension TMDBRoute {
    var cachePolicy: URLRequest.CachePolicy? { return nil }
}

protocol JSONInitializing {
    init(json: JSON) throws
}
