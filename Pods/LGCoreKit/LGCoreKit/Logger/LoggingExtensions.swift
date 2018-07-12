//
//  LoggingExtensions.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 02/03/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Alamofire

extension URLRequestAuthenticable {
    var debugMessage: String {
        var result  = urlRequest?.debugMessage ?? ""
        result     += " > Req authLevel: " + "\(requiredAuthLevel)\n"
        return result
    }
}

extension URLRequestAuthenticable {
    func host() throws -> String? {
        guard let url = try asURLRequest().url, let host = url.host else { return nil }
        return host
    }
    func path() throws -> String? {
        if let url = try asURLRequest().url {
           return url.path
        }
        return nil
    }
}

extension URLRequest {
    var debugMessage: String {
        var httpBody: String?
        if let bodyData = self.httpBody,
            let body = String(data: bodyData, encoding: .utf8) {
            
            let maxChars = 20
            if body.count > maxChars {
                let lowerBound = body.startIndex
                let upperBound = body.index(lowerBound, offsetBy: maxChars)
                httpBody = body[lowerBound..<upperBound] + "..."
            } else {
                httpBody = body
            }
        }
        let httpHeaders: String? = allHTTPHeaderFields?.description

        var output  = "\n"
        output     += "Request:          " + "\(String(describing: httpMethod)) \(String(describing: url?.absoluteString))\n"
        output     += " >          Body: " + "\(String(describing: httpBody))\n"
        output     += " >       Headers: " + "\(String(describing: httpHeaders))\n"
        return output
    }
}

extension DataResponse {
    var debugMessage: String {
        let httpMethod = request?.urlRequest?.httpMethod
        let urlString = request?.url?.absoluteString
        let statusCode = response?.statusCode
        let error = result.error
        var httpBody: String?
        if let bodyData = data,
            let body = String(data: bodyData, encoding: .utf8) {
            
            let maxChars = 20
            if body.count > maxChars {
                let lowerBound = body.startIndex
                let upperBound = body.index(lowerBound, offsetBy: maxChars)
                httpBody = body[lowerBound..<upperBound] + "..."
            } else {
                httpBody = body
            }

        }
        let httpHeaders: String? = response?.allHeaderFields.description

        var output  = "\n"
        output     += "Response:         " + "\(String(describing: httpMethod)) \(String(describing: urlString))\n"
        output     += " >   Status code: " + "\(String(describing: statusCode))\n"
        output     += " >         Error: " + "\(String(describing: error))\n"
        output     += " >          Body: " + "\(String(describing: httpBody))\n"
        output     += " >       Headers: " + "\(String(describing: httpHeaders))\n"
        return output
    }
}
