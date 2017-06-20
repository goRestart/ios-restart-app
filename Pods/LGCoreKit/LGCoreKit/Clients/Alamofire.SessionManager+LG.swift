//
//  Alamofire.SessionManager+LG.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 18/05/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Alamofire

extension Alamofire.SessionManager {
    static func make(backgroundEnabled: Bool, userAgentBuilder: UserAgentBuilder?) -> Alamofire.SessionManager {
        let configuration: URLSessionConfiguration
        if backgroundEnabled {
            configuration = URLSessionConfiguration
                .background(withIdentifier: LGCoreKitConstants.networkBackgroundIdentifier)
        } else {
            configuration = URLSessionConfiguration.default
        }
        var headers = Alamofire.SessionManager.defaultHTTPHeaders
        if let userAgentBuilder = userAgentBuilder {
            headers["User-Agent"] = userAgentBuilder.make(appBundle: Bundle.main)
        }
        configuration.httpAdditionalHeaders = headers
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        return Alamofire.SessionManager(configuration: configuration)
    }
}
