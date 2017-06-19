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
        var result  = urlRequest?.logMessage ?? ""
        result     += " > Req authLevel: " + "\(requiredAuthLevel)\n"
        return result
    }
}

extension URLRequest {
    var logMessage: String {
        var httpBody: String?
        if let bodyData = self.httpBody,
            let body = String(data: bodyData, encoding: .utf8) {
            
            let maxChars = 20
            if body.characters.count > maxChars {
                httpBody = body.substring(to: body.index(body.startIndex, offsetBy: maxChars)) + "..."
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
    var logMessage: String {
        let httpMethod = request?.urlRequest?.httpMethod
        let urlString = request?.url?.absoluteString
        let statusCode = response?.statusCode
        let error = result.error
        var httpBody: String?
        if let bodyData = data,
            let body = String(data: bodyData, encoding: .utf8) {
            
            let maxChars = 20
            if body.characters.count > maxChars {
                httpBody = body.substring(to: body.index(body.startIndex, offsetBy: maxChars)) + "..."
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
