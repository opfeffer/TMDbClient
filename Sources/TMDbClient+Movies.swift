//
//  TMDbClient+Movies.swift
//  TMDbClient
//
//  Created by Oliver Pfeffer on 3/9/17.
//  Copyright © 2017 Astrio, LLC. All rights reserved.
//

import Foundation
import PromiseKit

extension TMDbClient {
    public struct Movies {

        public enum Appends: String {
            case credits, releases, videos
        }

        enum Router: TMDbRoute {
            case credits(movieId: Int)

            case details(movieId: Int, appends: Set<Appends>?)

            var path: String {
                switch self {
                case .credits(let movieId):
                    return "/movie/\(movieId)/credits"
                case .details(let movieId, _):
                    return "/movie/\(movieId)"
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


        public static func details(movieId: Int, appends: Set<Appends>? = nil) -> Promise<Movie> {
            let rq = Router.details(movieId: movieId, appends: appends)
            return TMDbClient.getObject(rq)
        }

        public static func credits(movieId: Int) -> Promise<Credits> {
            let rq = Router.credits(movieId: movieId)
            return TMDbClient.getObject(rq)
        }
    }
}
