//
//  Credits.swift
//  TMDbClient
//
//  Created by Oliver Pfeffer on 3/12/17.
//  Copyright © 2017 Astrio, LLC. All rights reserved.
//

import Foundation
import Swift

public protocol Credit {
    var id: Int { get }
    var creditId: String { get }
    var name: String { get }
}

public struct Credits: JSONInitializing {
    public let cast: [Cast]?
    public let crew: [Crew]?

    init(json: JSON) throws {
        guard let data = json as? JSONDictionary else { throw SerializationError.unexpectedRootNode(json) }

        var raw: [JSONDictionary]? = try? data.get("crew")
        crew = raw?.flatMap { try? Crew(json: $0) }

        raw = try? data.get("cast")
        cast = raw?.flatMap { try? Cast(json: $0) }
    }
}

extension Credits {

    public struct Cast: JSONInitializing {
        public let id: Int
        public let creditId: String
        public let name: String
        public let profilePath: String?

        public let castId: Int
        public let character: String

        init(json: JSON) throws {
            guard let data = json as? JSONDictionary else { throw SerializationError.unexpectedRootNode(json) }

            id = try data.get("id")
            creditId = try data.get("credit_id")
            name = try data.get("name")
            profilePath = try? data.get("profile_path")

            castId = try data.get("cast_id")
            character = try data.get("character")
        }
    }

    public struct Crew: JSONInitializing {
        public let id: Int
        public let creditId: String
        public let name: String
        public let profilePath: String?

        public let department: String
        public let job: String

        init(json: JSON) throws {
            guard let data = json as? JSONDictionary else { throw SerializationError.unexpectedRootNode(json) }

            id = try data.get("id")
            creditId = try data.get("credit_id")
            name = try data.get("name")
            profilePath = try? data.get("profile_path")

            department = try data.get("department")
            job = try data.get("job")
        }
    }

}
