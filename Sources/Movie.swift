//
//  Movie.swift
//  TMDbClient
//
//  Created by Oliver Pfeffer on 3/10/17.
//  Copyright © 2017 Astrio, LLC. All rights reserved.
//

import Foundation

public struct Movie: JSONInitializing {
    let id: Int
    let title: String

    let imdbId: String?

    init(json: JSON) throws {
        guard let json = json as? JSONDictionary,
            let id = json["id"] as? Int,
            let title = json["title"] as? String
            else { throw SerializationError.missingProperty }

        self.id = id
        self.title = title
        self.imdbId = json["imdb_id"] as? String
    }
}

