//
//  LGNotificationTextModule.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 07/03/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

public struct LGNotificationTextModule: NotificationTextModule {
    public let title: String?
    public let body: String
    public let deeplink: String?
}

extension LGNotificationTextModule: Decodable {
    private struct JSONKeys {
        static let title = "title_text"
        static let body = "body_text"
        static let deeplink = "deeplink"
    }
    
    public static func decode(_ j: JSON) -> Decoded<LGNotificationTextModule> {
        /*
         {
         "title_text": "THIS MIGHT BE NULL",
         "body_text": "this can't be null",
         "deeplink": "THIS MIGHT BE NULL"
         }
         */
        let result1 = curry(LGNotificationTextModule.init)
        let result2 = result1 <^> j <|? JSONKeys.title
        let result3 = result2 <*> j <| JSONKeys.body
        let result  = result3 <*> j <|? JSONKeys.deeplink
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGNotificationTextModule parse error: \(error)")
        }
        return result
    }
}
