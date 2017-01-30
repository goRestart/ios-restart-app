//
//  BumpeableProduct.swift
//  LGCoreKit
//
//  Created by Dídac on 22/12/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public protocol BumpeableProduct {
    var isBumpeable: Bool { get }
    var countdown: Int { get }          // milliseconds
    var maxCountdown: Int { get }       // milliseconds
    var totalBumps: Int { get }
    var bumpsLeft: Int { get }
    var timeSinceLastBump: Int { get }  // milliseconds
    var paymentItems: [PaymentItem] { get }
}
