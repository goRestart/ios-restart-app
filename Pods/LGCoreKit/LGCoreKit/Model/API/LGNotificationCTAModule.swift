//
//  LGNotificationCTAModule.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 27/02/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//


import Argo
import Curry
import Runes


public struct LGNotificationCTAModule: NotificationCTAModule {
    public let title: String
    public let deeplink: String
}

extension LGNotificationCTAModule: Decodable {
    private struct JSONKeys {
        static let text = "text"
        static let deeplink = "deeplink"
    }
    
    public static func decode(_ j: JSON) -> Decoded<LGNotificationCTAModule> {
        /*
         {
         "text": "some text",
         "deeplink": "some deeplink that can't be null"
         }
         */
        let result1 = curry(LGNotificationCTAModule.init)
        let result2 = result1 <^> j <| JSONKeys.text
        let result  = result2 <*> j <| JSONKeys.deeplink
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGNotificationCTAModule parse error: \(error)")
        }
        return result
    }
}

