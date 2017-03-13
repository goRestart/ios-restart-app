//
//  LGNotificationImageModule.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 07/03/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//



import Argo
import Curry
import Runes

public struct LGNotificationImageModule: NotificationImageModule {
    public let shape: NotificationImageShape?
    public let imageURL: String
    public let deeplink: String?
}

extension LGNotificationImageModule: Decodable {
    private struct JSONKeys {
        static let shape    = "shape"
        static let imageURL = "image"
        static let deeplink = "deeplink"
    }
    
    init(shape: String?, imageURL: String, deeplink: String?) {
        self.shape = NotificationImageShape(rawValue: shape ?? "")
        self.imageURL = imageURL
        self.deeplink = deeplink
    }
    
    public static func decode(_ j: JSON) -> Decoded<LGNotificationImageModule> {
        /*
         {
         "shape": "circle" // circle or square, might be nil
         "image": "some url that can't be null",
         "deeplink": "THIS MIGHT BE NULL"         }
         */
        return curry(LGNotificationImageModule.init)
            <^> j <|? JSONKeys.shape
            <*> j <| JSONKeys.imageURL
            <*> j <|? JSONKeys.deeplink
    }
}
