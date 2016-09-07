//
//  Alamofire.Manager+LG.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 18/05/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Alamofire

extension Manager {
    static func lgManager(backgroundEnabled: Bool) -> Manager {
        let configuration: NSURLSessionConfiguration
        if backgroundEnabled {
            configuration = NSURLSessionConfiguration
                .backgroundSessionConfigurationWithIdentifier(LGCoreKitConstants.networkBackgroundIdentifier)
        } else {
            configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        }
        configuration.HTTPAdditionalHeaders = Manager.defaultHTTPHeaders
        configuration.requestCachePolicy = .ReloadIgnoringLocalCacheData
        return Manager(configuration: configuration)
    }
}
