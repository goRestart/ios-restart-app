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
        return curry(LGNotificationTextModule.init)
            <^> j <|? JSONKeys.title
            <*> j <| JSONKeys.body
            <*> j <|? JSONKeys.deeplink
    }
}
