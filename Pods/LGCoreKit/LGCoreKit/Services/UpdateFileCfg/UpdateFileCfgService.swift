//
//  UpdateFileCfgService.swift
//  Pods
//
//  Created by Dídac on 06/08/15.
//
//

import Result

public enum UpdateFileCfgServiceError: Printable {
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

public typealias UpdateFileCfgServiceResult = (Result<UpdateFileCfg, UpdateFileCfgServiceError>) -> Void

public protocol UpdateFileCfgService {
    
    var cfgFileURL : String { get }
    
    /**
        Retrieves the products with the given parameters.
    
        :param: result The completion closure.
    */
    func retrieveCfgFileWithResult(result: UpdateFileCfgServiceResult?)
}
