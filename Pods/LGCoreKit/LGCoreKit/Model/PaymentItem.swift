//
//  PaymentItem.swift
//  LGCoreKit
//
//  Created by Dídac on 10/01/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

public protocol PaymentItem {
    var provider: PaymentProvider { get }
    var itemId: String { get }
    var providerItemId: String { get }
}
