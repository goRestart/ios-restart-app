//
//  BumpeableListing.swift
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
