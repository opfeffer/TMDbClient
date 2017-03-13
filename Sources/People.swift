//
//  People.swift
//  TMDbClient
//
//  Created by Oliver Pfeffer on 3/11/17.
//  Copyright © 2017 Astrio, LLC. All rights reserved.
//

import Foundation

public struct Person: JSONInitializing {
    public let id: Int
    public let name: String

    public let imdbId: String?

    init(json: JSON) throws {
        guard let data = json as? JSONDictionary else { throw SerializationError.unexpectedRootNode(json) }

        id = try data.get("id")
        name = try data.get("name")
        imdbId = try? data.get("imdb_id")
    }
}
