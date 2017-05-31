
//
//  Transaction.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 22/05/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

public protocol Transaction {
    var transactionId: String { get }
    var closed: Bool { get }
}
