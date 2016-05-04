//
//  LoggingExtensions.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 02/03/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Alamofire

extension URLRequestAuthenticable {
    var logMessage: String {
        var result  = URLRequest.logMessage
        result     += " > Req authLevel: " + "\(requiredAuthLevel)\n"
        return result
    }
}

extension NSURLRequest {
    var logMessage: String {
        var httpBody: String = "nil"
        if let bodyData = URLRequest.HTTPBody, body = NSString(data: bodyData, encoding: NSUTF8StringEncoding) {
            let maxChars = 20
            if body.length > maxChars {
                httpBody = body.substringToIndex(maxChars) + "..."
            } else {
                httpBody = body as String
            }
        }
        let httpHeaders: String = URLRequest.allHTTPHeaderFields?.description ?? "nil"

        var result = "\n"
        result     += "Request:          " + "\(URLRequest.HTTPMethod) \(URLRequest.URLString)\n"
        result     += " >          Body: " + "\(httpBody)\n"
        result     += " >       Headers: " + "\(httpHeaders)\n"
        return result
    }
}

extension Response {
    var logMessage: String {
        let httpMethod = request?.HTTPMethod ?? "nil"
        let urlString = request?.URLString ?? "nil"
        let statusCode = response?.statusCode ?? -1
        var httpBody: String = "nil"
        if let bodyData = data, body = NSString(data: bodyData, encoding: NSUTF8StringEncoding) {
            let maxChars = 20
            if body.length > maxChars {
                httpBody = body.substringToIndex(maxChars) + "..."
            } else {
                httpBody = body as String
            }

        }
        let httpHeaders: String = response?.allHeaderFields.description ?? "nil"

        var result = "\n"
        result     += "Response:         " + "\(httpMethod) \(urlString)\n"
        result     += " >   Status code: " + "\(statusCode)\n"
        result     += " >          Body: " + "\(httpBody)\n"
        result     += " >       Headers: " + "\(httpHeaders)\n"
        return result
    }
}
