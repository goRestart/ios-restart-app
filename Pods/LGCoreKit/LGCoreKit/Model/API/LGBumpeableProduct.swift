//
//  LGBumpeableProduct.swift
//  LGCoreKit
//
//  Created by Dídac on 22/12/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

public struct LGBumpeableProduct : BumpeableProduct {
    private static let millisToSeconds: Int64 = 1000

    public let isBumpeable: Bool
    public let countdown: TimeInterval
    public let maxCountdown: TimeInterval
    public let totalBumps: Int
    public let bumpsLeft: Int
    public let timeSinceLastBump: TimeInterval
    public let paymentItems: [PaymentItem]

    init(isBumpeable: Bool, countdown: Int64, maxCountdown: Int64, totalBumps: Int, bumpsLeft: Int,
         timeSinceLastBump: Int64, paymentItems: [LGPaymentItem]) {
        self.isBumpeable = isBumpeable
        self.countdown = TimeInterval(countdown)/TimeInterval(LGBumpeableProduct.millisToSeconds)
        self.maxCountdown = TimeInterval(maxCountdown)/TimeInterval(LGBumpeableProduct.millisToSeconds)
        self.totalBumps = totalBumps
        self.bumpsLeft = bumpsLeft
        self.timeSinceLastBump = TimeInterval(timeSinceLastBump)/TimeInterval(LGBumpeableProduct.millisToSeconds)
        self.paymentItems = paymentItems.flatMap { $0 }
    }
}


extension LGBumpeableProduct: Decodable {

    /**
     Expects a json in the form:
     
     {
        "is_bumpeable": true, // boolean
        "countdown": 213234546675, // milliseconds until can be bumped again
        "max_countdown": 213234546675, // Max countdown for this type of bump (i.e. when has just been bumped)
        "total_bumps": 3, // int, number of times the the product can be bumped
        "remaining_bumps": 0 // int, remaining bumps,
        "millis_since_last_bump_up", //milliseconds ellapsed since last bump up
        "payment_items": [
            {
                "provider": "free",  // string, possible values ["letgo", "apple", "google"]
                "item_id": "4c72134c5-6586-798" // string, uuid4
                "provider_item_id": "com.letgo.tier1" // string, external provider ID, depending on google, apple, etc.
            },
            ...
        ]
     }

     */
    public static func decode(_ j: JSON) -> Decoded<LGBumpeableProduct> {

        let result = curry(LGBumpeableProduct.init)
            <^> j <| "is_bumpeable"
            <*> j <| "countdown"
            <*> j <| "max_countdown"
            <*> j <| "total_bumps"
            <*> j <| "remaining_bumps"
            <*> j <| "millis_since_last_bump_up"
            <*> j <|| "payment_items"

        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGBumpeableProduct parse error: \(error)")
        }
        return result
    }
}
