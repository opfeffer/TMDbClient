//
//  TMDbDateConverter.swift
//  TMDbClient
//
//  Created by Oliver Pfeffer on 3/13/17.
//  Copyright © 2017 Astrio, LLC. All rights reserved.
//

import Foundation

struct TMDbDateConverter {
    enum Error: Swift.Error {
        case conversionFailed
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static func date(from string: String) throws -> Date {
        guard let date = dateFormatter.date(from: string) else { throw Error.conversionFailed }
        return date
    }
    
}
