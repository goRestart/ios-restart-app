//
//  ConfigRetrieveService.swift
//  Pods
//
//  Created by Dídac on 06/08/15.
//
//

import Result

enum ConfigRetrieveServiceError: Error, CustomStringConvertible {
    case network
    case internalError

    var description: String {
        switch (self) {
        case .network:
            return "Network"
        case .internalError:
            return "Internal"
        }
    }
}

typealias ConfigRetrieveServiceResult = Result<Config, ConfigRetrieveServiceError>
typealias ConfigRetrieveServiceCompletion = (ConfigRetrieveServiceResult) -> Void

protocol ConfigRetrieveService {

    /**
        Retrieves the config file.

        - parameter completion: The completion closure.
    */
    func retrieveConfigWithCompletion(_ completion: ConfigRetrieveServiceCompletion?)
}
