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
        static let productId = "product_id"
        static let productTitle = "product_title"
        static let productImage = "product_image"
    }

    public static func decode(_ j: JSON) -> Decoded<LGNotificationListing> {
        /*
         {
         "product_id": "a569527f-17e2-3d22-a513-2fc0c6477ac8",
         "product_image": "Ms.",
         "product_title": "Miss",
         }
         */
        return curry(LGNotificationListing.init)
            <^> j <| JSONKeys.productId
            <*> j <|? JSONKeys.productTitle
            <*> j <|? JSONKeys.productImage
    }
}

