//
//  Alamofire.Manager+LG.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 18/05/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Alamofire

extension Manager {
    static var lgManager: Manager {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = Manager.defaultHTTPHeaders
        configuration.requestCachePolicy = .ReloadIgnoringLocalCacheData
        return Manager(configuration: configuration)
    }
}
