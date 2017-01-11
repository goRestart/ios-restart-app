//
//  LGBumpeableProduct.swift
//  LGCoreKit
//
//  Created by Dídac on 22/12/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry

public struct LGBumpeableProduct : BumpeableProduct {
    public let isBumpeable: Bool
    public let countdown: Int
    public let totalBumps: Int
    public let bumpsLeft: Int
    public let paymentItems: [PaymentItem]

    init(isBumpeable: Bool, countdown: Int, totalBumps: Int, bumpsLeft: Int, paymentItems: [LGPaymentItem]) {
        self.isBumpeable = isBumpeable
        self.countdown = countdown
        self.totalBumps = totalBumps
        self.bumpsLeft = bumpsLeft
        self.paymentItems = paymentItems.flatMap { $0 }
    }
}


extension LGBumpeableProduct: Decodable {

    /**
     Expects a json in the form:

     {
        "is_bumpeable": true, // boolean
        "countdown": 213234546675, // milliseconds until can be bumped again
        "total_bumps": 3, // int, number of times the the product can be bumped
        "remaining_bumps": 0 // int, remaining bumps
        "payment_items": [ LGPaymentItem , ... ]
     }

     */
    public static func decode(j: JSON) -> Decoded<LGBumpeableProduct> {

        let result = curry(LGBumpeableProduct.init)
            <^> j <| "is_bumpeable"
            <*> j <| "countdown"
            <*> j <| "total_bumps"
            <*> j <| "remaining_bumps"
            <*> j <|| "payment_items"

        if let error = result.error {
            logMessage(.Error, type: CoreLoggingOptions.Parsing, message: "LGBumpeableProduct parse error: \(error)")
        }
        return result
    }
}
