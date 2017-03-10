//
//  URLJSONPromise.swift
//  TMDbClient
//
//  Created by Oliver Pfeffer on 3/8/17.
//  Copyright © 2017 Astrio, LLC. All rights reserved.
//

import Foundation
import PromiseKit


public class URLJSONPromise: Promise<Transmission> {

    public func asDictionary() -> Promise<JSONDictionary> {
        return asType()
    }

    public func asArray() -> Promise<JSONArray> {
        return asType()
    }

    public func asType<T>() -> Promise<T> {
        return then(on: waldo) { (_,_, json) -> T in
            guard let json = json else { throw SerializationError.emptyResponse }
            guard let value = json as? T else { throw SerializationError.unexpectedRootNode(json) }

            return value
        }
    }

    // Internal methods

    private(set) var urlRequest: URLRequest!
    private(set) var urlResponse: URLResponse!

    fileprivate class func go(_ request: URLRequest, body: (@escaping (Data?, URLResponse?, Error?) -> Void) -> Void) -> URLJSONPromise {
        let (p, fulfill, reject) = URLJSONPromise.pending()
        let promise = p as! URLJSONPromise
        promise.urlRequest = request

        body { data, rsp, error in
            promise.urlResponse = rsp

            let data = data ?? Data()
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)

            if let error = error {
                let e = URLSessionError.cocoaError(error, request: request)
                reject(e)
            } else if let rsp = rsp as? HTTPURLResponse, 200..<300 ~= rsp.statusCode {
                let transmission = (request, rsp, json)
                fulfill(transmission)
            } else {
                let e = URLSessionError.badResponse(rsp as? HTTPURLResponse, request: request, json: json)
                reject(e)
            }
        }

        return promise
    }

}

extension URLSession {
    /// Makes a HTTP request using the parameters specified by the provided URL request.
    public func jsonTask(with request: URLRequest) -> URLJSONPromise {
        return URLJSONPromise.go(request) { completionHandler in
            dataTask(with: request, completionHandler: completionHandler).resume()
        }
    }
}

public enum URLSessionError: Swift.Error {
    case cocoaError(Error, request: URLRequest)
    case badResponse(HTTPURLResponse?, request: URLRequest, json: JSON?)
    case noJSONPayload
}

public enum SerializationError: Swift.Error {
    case emptyResponse
    case unexpectedRootNode(Any)
    case missingProperty
}
