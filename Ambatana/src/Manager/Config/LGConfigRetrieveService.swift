//
//  LGConfigFileRetrieveService.swift
//  LGCoreKit
//
//  Created by Dídac on 10/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import Result
import LGCoreKit

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
            .responseJSON { response in
                if let data = response.data {
                    do {
                        let config = try JSONDecoder().decode(Config.self, from: data)
                        completion?(ConfigRetrieveServiceResult(value: config))
                    } catch {
                        logMessage(.debug, type: .parsing, message: "Could not decode config data: \(data)")
                        completion?(ConfigRetrieveServiceResult(error: .internalError))
                    }
                } else if let afError = response.error as? AFError,
                    let _ = afError.underlyingError as? URLError {
                    completion?(ConfigRetrieveServiceResult(error: .network))
                } else if let _ = response.error as? URLError {
                    completion?(ConfigRetrieveServiceResult(error: .network))
                } else  {
                    completion?(ConfigRetrieveServiceResult(error: .internalError))
                }
            }
    }
}
