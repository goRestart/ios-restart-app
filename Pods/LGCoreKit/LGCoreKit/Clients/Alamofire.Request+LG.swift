//
//  Alamofire.Request+LG.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire

public protocol ResponseObjectSerializable {
    init?(response: NSHTTPURLResponse, representation: AnyObject)
}

extension Request {
    public func responseObject<T: ResponseObjectSerializable>(completionHandler: Response<T, NSError> -> Void) -> Self {
        let responseSerializer = ResponseSerializer<T, NSError> { request, response, data, error in
            guard error == nil else { return .Failure(error!) }

            let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, data, error)

            switch result {
            case .Success(let value):
                if let response = response, responseObject = T(response: response, representation: value) {
                    return .Success(responseObject)
                } else {
                    return .Failure(Request.serializationError(value))
                }
            case .Failure(let error):
                return .Failure(error)
            }
        }

        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }

    public func responseObject<T>(decoder: AnyObject -> T?, completionHandler: Response<T, NSError> -> Void) -> Self {
        let responseSerializer = ResponseSerializer<T, NSError> { request, response, data, error in
            guard error == nil else { return .Failure(error!) }

            var result: Result<AnyObject, NSError>

            if (200..<400).contains(response?.statusCode ?? 0) && response?.expectedContentLength == 0 {
                // If the response is empty we can't serialize it, but it may be a success
                result = .Success("")
            } else if response?.statusCode == 304 {
                // 304 doesn't provide content-length == 0 even though the content is empty
                result = .Success("")
            } else {
                let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
                result = JSONResponseSerializer.serializeResponse(request, response, data, error)
            }

            switch result {
            case .Success(let value):
                if let responseObject = decoder(value) {
                    return .Success(responseObject)
                } else {
                    return .Failure(Request.serializationError(value))
                }
            case .Failure(let error):
                return .Failure(error)
            }
        }

        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }

    private static func serializationError(responseObject: AnyObject) -> NSError {
        let failureReason = "JSON could not be serialized into response object: \(responseObject)"
        let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
        return NSError(domain: Error.Domain, code: Error.Code.JSONSerializationFailed.rawValue,
                       userInfo: userInfo)
    }
}
