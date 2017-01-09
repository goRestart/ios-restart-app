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
        Alamofire.request(.GET, configURL)
            .validate(statusCode: 200..<400)
            .responseObject { (configFileResponse: Response<Config, NSError>) -> Void in
                // Success
                if let configFile = configFileResponse.result.value {
                    completion?(ConfigRetrieveServiceResult(value: configFile))
                }
                // Error
                else if let error = configFileResponse.result.error {
                    if error.domain == URLErrorDomain {
                        completion?(ConfigRetrieveServiceResult(error: .Network))
                    }
                    else {
                        completion?(ConfigRetrieveServiceResult(error: .internalError))
                    }
                }
                else {
                    completion?(ConfigRetrieveServiceResult(error: .internalError))
                }
            }
    }
}
