//
//  LGBumpeableListing.swift
//  LGCoreKit
//
//  Created by Dídac on 22/12/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public protocol BumpeableListing {
    var isBumpeable: Bool { get }
    var countdown: TimeInterval { get }
    var maxCountdown: TimeInterval { get }
    var totalBumps: Int { get }
    var bumpsLeft: Int { get }
    var timeSinceLastBump: TimeInterval { get }
    var paymentItems: [PaymentItem] { get }
}

public struct LGBumpeableListing: BumpeableListing, Decodable {

    public let isBumpeable: Bool
    public let countdown: TimeInterval
    public let maxCountdown: TimeInterval
    public let totalBumps: Int
    public let bumpsLeft: Int
    public let timeSinceLastBump: TimeInterval
    public let paymentItems: [PaymentItem]

    // MARK: Decode
    
    /*
     {
     "is_bumpeable": true, // boolean
     "countdown": 213234546675, // milliseconds until can be bumped again
     "max_countdown": 213234546675, // Max countdown for this type of bump (i.e. when has just been bumped)
     "total_bumps": 3, // int, number of times the listing can be bumped
     "remaining_bumps": 0 // int, remaining bumps,
     "millis_since_last_bump_up", //milliseconds ellapsed since last bump up
     "payment_items": [
         {
         "provider": "letgo",  // string, possible values, last one has a special 'ⅼ' for hidden items ["letgo", "apple", "google", "letgo.apple"]
         "item_id": "4c72134c5-6586-798" // string, uuid4
         "provider_item_id": "com.letgo.tier1" // string, external provider ID, depending on google, apple, etc.
         }
     ]
     }
     */
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        isBumpeable = try keyedContainer.decode(Bool.self, forKey: .isBumpeable)
        let countdownValue = try keyedContainer.decode(Int64.self, forKey: .countdown)
        countdown = TimeInterval(countdownValue) / 1000
        let maxCountdownValue = try keyedContainer.decode(Int64.self, forKey: .maxCountdown)
        maxCountdown = TimeInterval(maxCountdownValue) / 1000
        totalBumps = try keyedContainer.decode(Int.self, forKey: .totalBumps)
        bumpsLeft = try keyedContainer.decode(Int.self, forKey: .bumpsLeft)
        let timeSinceLastBumpValue = try keyedContainer.decode(Int64.self, forKey: .timeSinceLastBump)
        timeSinceLastBump = TimeInterval(timeSinceLastBumpValue) / 1000
        paymentItems = try keyedContainer.decode([LGPaymentItem].self, forKey: .paymentItems)
    }
    
    enum CodingKeys: String, CodingKey {
        case isBumpeable = "is_bumpeable"
        case countdown = "countdown"
        case maxCountdown = "max_countdown"
        case totalBumps = "total_bumps"
        case bumpsLeft = "remaining_bumps"
        case timeSinceLastBump = "millis_since_last_bump_up"
        case paymentItems = "payment_items"
    }
}

