//
//  PaymentEnqueuable.swift
//  LetGo
//
//  Created by Dídac on 14/03/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import StoreKit

protocol PaymentEnqueuable {

    var canMakePayments: Bool { get }

    var transactions: [SKPaymentTransaction] { get }

    func add(_ payment: SKPayment)
    func restoreCompletedTransactions()
    func restoreCompletedTransactions(withApplicationUsername username: String?)
    func finishTransaction(_ transaction: SKPaymentTransaction)
    func start(_ downloads: [SKDownload])
    func pause(_ downloads: [SKDownload])
    func resume(_ downloads: [SKDownload])
    func cancel(_ downloads: [SKDownload])

    func add(_ observer: SKPaymentTransactionObserver)
    func remove(_ observer: SKPaymentTransactionObserver)
}

extension SKPaymentQueue: PaymentEnqueuable {
    var canMakePayments: Bool {
        get {
            return SKPaymentQueue.canMakePayments()
        }
    }
}
