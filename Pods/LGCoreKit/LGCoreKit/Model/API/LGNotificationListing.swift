//
//  LGNotificationListing.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 22/12/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

public struct LGNotificationListing: NotificationListing {
    public let id: String
    public let title: String?
    public let image: String?
}

extension LGNotificationListing: Decodable {
    private struct JSONKeys {
        static let listingId = "product_id"
        static let listingTitle = "product_title"
        static let listingImage = "product_image"
    }

    public static func decode(_ j: JSON) -> Decoded<LGNotificationListing> {
        /*
         {
         "product_id": "a569527f-17e2-3d22-a513-2fc0c6477ac8",
         "product_title": "Ms.",
         "product_image": "Miss",
         }
         */       
        let result1 = curry(LGNotificationListing.init)
        let result2 = result1 <^> j <| JSONKeys.listingId
        let result3 = result2 <*> j <|? JSONKeys.listingTitle
        let result  = result3 <*> j <|? JSONKeys.listingImage
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGNotificationListing parse error: \(error)")
        }
        return result
    }
}

