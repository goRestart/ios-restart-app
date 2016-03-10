//
//  ConfigRetrieveService.swift
//  Pods
//
//  Created by Dídac on 06/08/15.
//
//

import Result

public enum ConfigRetrieveServiceError: ErrorType, CustomStringConvertible {
    case Network
    case Internal

    public var description: String {
        switch (self) {
        case Network:
            return "Network"
        case Internal:
            return "Internal"
        }
    }
}

public typealias ConfigRetrieveServiceResult = Result<Config, ConfigRetrieveServiceError>
public typealias ConfigRetrieveServiceCompletion = ConfigRetrieveServiceResult -> Void

public protocol ConfigRetrieveService {

    /**
        Retrieves the config file.

        - parameter completion: The completion closure.
    */
    func retrieveConfigWithCompletion(completion: ConfigRetrieveServiceCompletion?)
}
