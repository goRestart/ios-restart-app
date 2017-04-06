//
//  Alamofire.Manager+LG.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 18/05/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Alamofire

extension Alamofire.SessionManager {
    static func lgManager(_ backgroundEnabled: Bool) -> Alamofire.SessionManager {
        let configuration: URLSessionConfiguration
        if backgroundEnabled {
            configuration = URLSessionConfiguration
                .background(withIdentifier: LGCoreKitConstants.networkBackgroundIdentifier)
        } else {
            configuration = URLSessionConfiguration.default
        }
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        return Alamofire.SessionManager(configuration: configuration)
    }
}
