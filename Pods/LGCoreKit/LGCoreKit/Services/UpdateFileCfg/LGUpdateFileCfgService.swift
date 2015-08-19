//
//  LGUpdateFileCfgService.swift
//  LGCoreKit
//
//  Created by Dídac on 10/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import Result

public class LGUpdateFileCfgService: UpdateFileCfgService {
   
    public private(set) var cfgFileURL : String
    
    // MARK: - Lifecycle
    
    public convenience init() {
        self.init(url: nil)
    }
    
    public init(url: String?) {
        if let actualURL = url where !actualURL.isEmpty {
            cfgFileURL = actualURL
        }
        else {
            cfgFileURL = EnvironmentProxy.sharedInstance.staticCfgFileURL
        }
    }
    
    // MARK: - Public Methods
    
    public func retrieveCfgFileWithResult(result: UpdateFileCfgServiceResult?) {
        Alamofire.request(.GET, cfgFileURL)
            .validate(statusCode: 200..<400)
            .responseObject { (_, _, updateFile: UpdateFileCfg?, error: NSError?) -> Void in
                // Error
                if let actualError = error {
                    let myError: NSError
                    if actualError.domain == NSURLErrorDomain {
                        result?(Result<UpdateFileCfg, UpdateFileCfgServiceError>.failure(.Network))
                    }
                    else {
                        result?(Result<UpdateFileCfg, UpdateFileCfgServiceError>.failure(.Internal))
                    }
                }
                    // Success
                else if let actualUpdateFile = updateFile {
                    result?(Result<UpdateFileCfg, UpdateFileCfgServiceError>.success(actualUpdateFile))
                }
        }
    }
}
