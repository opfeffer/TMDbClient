//
//  TMDbClient+People.swift
//  TMDbClient
//
//  Created by Oliver Pfeffer on 3/11/17.
//  Copyright © 2017 Astrio, LLC. All rights reserved.
//

import Foundation
import PromiseKit

extension TMDbClient {

    public struct People {

        public enum Appends: String {
            case movieCredits = "movie_credits"
            case tvCredits = "tv_credits"
            case externalIds = "external_ids"
        }

        enum Router: TMDbRoute {
            case details(personId: Int, appends: Set<Appends>?)

            var path: String {
                switch self {
                case .details(let personId, _):
                    return "/person/\(personId)"
                }
            }

            var parameters: Parameters? {
                switch self {
                case .details(_, .some(let appends)) where appends.isEmpty == false:
                    let value = appends.map { $0.rawValue }.joined(separator: ",")
                    return ["append_to_response": value]
                default:
                    return nil
                }
            }
        }

        public static func details(personId: Int, appends: Set<Appends>? = nil) -> Promise<Person> {
            let rq = Router.details(personId: personId, appends: appends)
            return TMDbClient.getObject(rq)
        }

    }
}
