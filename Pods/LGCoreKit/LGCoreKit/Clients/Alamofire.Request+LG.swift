//
//  Alamofire.Request+LG.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire

extension DataRequest {

    /*
     Converts response into DataResponse<T> using the provided decoder. This method DOESN'T check statusCodes as it assumes
     there's a previous validation. Will check if decoder accepts any kind of result if serialisation fails or body is empty
     */
    @discardableResult
    func responseObject<T>(_ decoder: @escaping (Any) -> T?, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {

        let responseSerializer = DataResponseSerializer<T> { (request, response, data, error) in
            if let error = error { return .failure(error) }

            var serializationResult: Result<Any>
            if let data = data, data.count > 0 {
                let jsonResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
                serializationResult = jsonResponseSerializer.serializeResponse(request, response, data, error)
            } else {
                serializationResult = .success("")
            }

            switch serializationResult {
            case .success(let value):
                if let responseObject = decoder(value) {
                    return .success(responseObject)
                } else {
                    return .failure(DataRequest.serializationError(value))
                }
            case .failure(let error):
                //Checking anyway just in case decoder doesn't care about response body
                if let responseObject = decoder("") {
                    return .success(responseObject)
                } else {
                    return .failure(error)
                }
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
