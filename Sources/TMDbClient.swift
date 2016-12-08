//
//  TMDbClient.swift
//  TMDbClient
//
//  Created by Oliver Pfeffer on 12/7/16.
//  Copyright © 2016 Astrio, LLC. All rights reserved.
//

import Foundation
import PromiseKit

public typealias Token = String

public class TMDbClient {

    /// Initialize the client with your TMDb-provided access token.
    ///
    /// - note: call in application(_:didFinishLaunchingWithOptions:)
    public class func initialize(with: Token) -> Promise<Void> {
        return Promise(value: ())
    }
}
