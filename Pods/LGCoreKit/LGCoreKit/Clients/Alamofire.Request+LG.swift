//
//  Alamofire.Request+LG.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire

public protocol ResponseObjectSerializable {
    init?(response: HTTPURLResponse, representation: Any)
}

extension DataRequest {

    @discardableResult
    public func responseObject<T: ResponseObjectSerializable>(_ completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        let responseSerializer = DataResponseSerializer<T> { request, response, data, error in
            if let error = error { return .failure(error) }

            let jsonResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            let result = jsonResponseSerializer.serializeResponse(request, response, data, error)

            switch result {
            case .success(let value):
                if let response = response, let responseObject = T(response: response, representation: value) {
                    return .success(responseObject)
                } else {
                    return .failure(DataRequest.serializationError(value))
                }
            case .failure(let error):
                return .failure(error)
            }
        }

        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }

    @discardableResult
    public func responseObject<T>(_ decoder: @escaping (Any) -> T?, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {

        let responseSerializer = DataResponseSerializer<T> { (request, response, data, error) in
            if let error = error { return .failure(error) }

            var result: Result<Any>

            if (200..<400).contains(response?.statusCode ?? 0) && response?.expectedContentLength == 0 {
                // If the response is empty we can't serialize it, but it may be a success
                result = .success("")
            } else if response?.statusCode == 304 {
                // 304 doesn't provide content-length == 0 even though the content is empty
                result = .success("")
            } else {
                let jsonResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
                result = jsonResponseSerializer.serializeResponse(request, response, data, error)
            }

            switch result {
            case .success(let value):
                if let responseObject = decoder(value) {
                    return .success(responseObject)
                } else {
                    return .failure(DataRequest.serializationError(value))
                }
            case .failure(let error):
                return .failure(error)
            }
        }

        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }

    private static func serializationError(_ responseObject: Any) -> Error {
        let failureReason = "JSON could not be serialized into response object: \(responseObject)"
        let decoderError = DecoderError(failureReason: failureReason)
        return AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: decoderError))
    }

    private struct DecoderError: Error {
        let failureReason: String
    }
}
