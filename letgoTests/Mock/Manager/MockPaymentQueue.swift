//
//  MockPaymentQueue.swift
//  LetGo
//
//  Created by Dídac on 14/03/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import StoreKit

class MockPaymentQueue: PaymentEnqueuable {

    var canMakePayments: Bool = true

    var transactions: [SKPaymentTransaction] = []

    func add(_ payment: SKPayment) {
        transactions.append(SKPaymentTransaction())
    }

    func finishTransaction(_ transaction: SKPaymentTransaction) {
        guard !transactions.isEmpty else { return }
        transactions.remove(at: 0)
    }

    func restoreCompletedTransactions() {
    }
    func restoreCompletedTransactions(withApplicationUsername username: String?) {
    }

    func start(_ downloads: [SKDownload]) {
    }
    func pause(_ downloads: [SKDownload]) {
    }
    func resume(_ downloads: [SKDownload]) {
    }
    func cancel(_ downloads: [SKDownload]) {
    }
    func add(_ observer: SKPaymentTransactionObserver) {
    }
    func remove(_ observer: SKPaymentTransactionObserver) {
    }
}
