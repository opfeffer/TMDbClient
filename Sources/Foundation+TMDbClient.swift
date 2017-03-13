//
//  Foundation+TMDbClient.swift
//  TMDbClient
//
//  Created by Oliver Pfeffer on 3/12/17.
//  Copyright © 2017 Astrio, LLC. All rights reserved.
//

import Foundation

extension Dictionary where Key: ExpressibleByStringLiteral {

    func get<T>(_ key: String) throws -> T {
        guard let value = self[key as! Key] as? T else { throw SerializationError.missingProperty(key) }
        return value
    }

    func transform<T, U>(_ key: String, transform: (U) throws -> T) throws -> T {
        guard let value = self[key as! Key] as? U else { throw SerializationError.missingProperty(key) }
        return try transform(value)
    }
    
}
