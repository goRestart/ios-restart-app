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
    
    public static func make(shape: String?,
                            imageURL: String,
                            deeplink: String?) -> LGNotificationImageModule {
        return LGNotificationImageModule(shape: NotificationImageShape(rawValue: shape ?? ""),
                                         imageURL: imageURL,
                                         deeplink: deeplink)
    }
    
    public static func decode(_ j: JSON) -> Decoded<LGNotificationImageModule> {
        /*
         {
           "shape": "circle" // circle or square, might be nil
           "image": "some url that can't be null",
           "deeplink": "THIS MIGHT BE NULL"
         }
         */
        let result1 = curry(LGNotificationImageModule.make)
        let result2 = result1 <^> j <|? JSONKeys.shape
        let result3 = result2 <*> j <| JSONKeys.imageURL
        let result  = result3 <*> j <|? JSONKeys.deeplink
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGNotificationImageModule parse error: \(error)")
        }
        return result
    }
}
