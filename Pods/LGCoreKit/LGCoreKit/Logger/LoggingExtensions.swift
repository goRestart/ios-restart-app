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
        var httpBody: String?
        if let bodyData = URLRequest.HTTPBody, body = NSString(data: bodyData, encoding: NSUTF8StringEncoding) {
            let maxChars = 20
            if body.length > maxChars {
                httpBody = body.substringToIndex(maxChars) + "..."
            } else {
                httpBody = body as String
            }
        }
        let httpHeaders: String? = URLRequest.allHTTPHeaderFields?.description

        var output  = "\n"
        output     += "Request:          " + "\(URLRequest.HTTPMethod) \(URLRequest.URLString)\n"
        output     += " >          Body: " + "\(httpBody)\n"
        output     += " >       Headers: " + "\(httpHeaders)\n"
        return output
    }
}

extension Response {
    var logMessage: String {
        let httpMethod = request?.HTTPMethod
        let urlString = request?.URLString
        let statusCode = String(response?.statusCode)
        let error = result.error
        var httpBody: String?
        if let bodyData = data, body = NSString(data: bodyData, encoding: NSUTF8StringEncoding) {
            let maxChars = 20
            if body.length > maxChars {
                httpBody = body.substringToIndex(maxChars) + "..."
            } else {
                httpBody = body as String
            }

        }
        let httpHeaders: String? = response?.allHeaderFields.description

        var output  = "\n"
        output     += "Response:         " + "\(httpMethod) \(urlString)\n"
        output     += " >   Status code: " + "\(statusCode)\n"
        output     += " >         Error: " + "\(error)\n"
        output     += " >          Body: " + "\(httpBody)\n"
        output     += " >       Headers: " + "\(httpHeaders)\n"
        return output
    }
}
