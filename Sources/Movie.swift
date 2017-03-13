//
//  Movie.swift
//  TMDbClient
//
//  Created by Oliver Pfeffer on 3/10/17.
//  Copyright © 2017 Astrio, LLC. All rights reserved.
//

import Foundation

public struct Movie: JSONInitializing {
    public let id: Int
    public let title: String
    public let releaseDate: Date

    public let imdbId: String?
    public let genres: [Genre]?

    public let credits: Credits?

    init(json: JSON) throws {
        guard let data = json as? JSONDictionary else { throw SerializationError.unexpectedRootNode(json) }

        id = try data.get("id")
        title = try data.get("title")

        releaseDate = try data.transform("release_date") { try TMDbDateConverter.date(from: $0) }
        imdbId = try? data.get("imdb_id")

        let genres: [JSONDictionary]? = try? data.get("genres")
        self.genres = genres?.flatMap { try? Genre(json: $0) }

        // Appends

        let credits = (try? data.get("credits")) ?? JSONDictionary()
        self.credits = try? Credits(json: credits)
    }
}


public extension Movie {

    public struct Genre: JSONInitializing {
        public let id: Int
        public let name: String

        init(json: JSON) throws {
            guard let data = json as? JSONDictionary else { throw SerializationError.unexpectedRootNode(json) }

            id = try data.get("id")
            name = try data.get("name")
        }
    }
}
