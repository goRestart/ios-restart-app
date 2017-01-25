//
//  LGConfigFileRetrieveService.swift
//  LGCoreKit
//
//  Created by Dídac on 10/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import Result

class LGConfigRetrieveService: ConfigRetrieveService {

    private(set) var configURL : String

    // MARK: - Lifecycle

    convenience init() {
        self.init(url: EnvironmentProxy.sharedInstance.configURL)
    }

    init(url: String?) {
        configURL = url ?? EnvironmentProxy.sharedInstance.configURL
    }

    // MARK: - Public Methods

    func retrieveConfigWithCompletion(_ completion: ConfigRetrieveServiceCompletion?) {

        Alamofire.request(configURL)
            .validate(statusCode: 200..<400)
            .responseObject { (configFileResponse: DataResponse<Config>) -> Void in
                // Success
                if let configFile = configFileResponse.result.value {
                    completion?(ConfigRetrieveServiceResult(value: configFile))
                }
                    // Error
                else if let error = configFileResponse.result.error {
                    if let afError = error as? AFError, let _ = afError.underlyingError as? URLError {
                        completion?(ConfigRetrieveServiceResult(error: .network))
                    } else if let _ = error as? URLError {
                        completion?(ConfigRetrieveServiceResult(error: .network))
                    } else  {
                        completion?(ConfigRetrieveServiceResult(error: .internalError))
                    }
                }
                else {
                    completion?(ConfigRetrieveServiceResult(error: .internalError))
                }
            }
    }
}

extension DataRequest {

    @discardableResult
    func responseObject<T: ResponseObjectSerializable>(_ completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        let responseSerializer = DataResponseSerializer<T> { request, response, data, error in
            if let error = error { return .failure(error) }

            let jsonResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            let result = jsonResponseSerializer.serializeResponse(request, response, data, error)

            switch result {
            case .success(let value):
                if let response = response, let responseObject = T(response: response, representation: value) {
                    return .success(responseObject)
                } else {
                    let error = AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: NSError()))
                    return .failure(error)
                }
            case .failure(let error):
                return .failure(error)
            }
        }

        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
}
