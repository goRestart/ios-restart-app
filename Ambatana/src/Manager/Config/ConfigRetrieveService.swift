//
//  ConfigRetrieveService.swift
//  Pods
//
//  Created by Dídac on 06/08/15.
//
//

import Result

public enum ConfigRetrieveServiceError: Error, CustomStringConvertible {
    case network
    case `internal`

    public var description: String {
        switch (self) {
        case .network:
            return "Network"
        case internal:
            return "Internal"
        }
    }
}

public typealias ConfigRetrieveServiceResult = Result<Config, ConfigRetrieveServiceError>
public typealias ConfigRetrieveServiceCompletion = (ConfigRetrieveServiceResult) -> Void

public protocol ConfigRetrieveService {

    /**
        Retrieves the config file.

        - parameter completion: The completion closure.
    */
    func retrieveConfigWithCompletion(_ completion: ConfigRetrieveServiceCompletion?)
}
