//
//  FailedBumpInfo.swift
//  LetGo
//
//  Created by Dídac on 12/09/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

struct FailedBumpInfo {

    static let listingIdKey = "listingId"
    static let transactionIdKey = "transactionId"
    static let paymentIdKey = "paymentId"
    static let receiptDataKey = "receiptData"
    static let itemIdKey = "itemId"
    static let itemPriceKey = "itemPrice"
    static let itemCurrencyKey = "itemCurrency"
    static let amplitudeIdKey = "amplitudeId"
    static let appsflyerIdKey = "appsflyerId"
    static let idfaKey = "idfa"
    static let bundleIdKey = "bundleId"
    static let numRetriesKey = "numRetries"

    let listingId: String
    let transactionId: String?
    let paymentId: String
    let receiptData: String
    let itemId: String
    let itemPrice: String
    let itemCurrency: String
    let amplitudeId: String?
    let appsflyerId: String?
    let idfa: String?
    let bundleId: String?
    let numRetries: Int

    init(listingId: String, transactionId: String?, paymentId: String, receiptData: String, itemId: String, itemPrice: String,
         itemCurrency: String, amplitudeId: String?, appsflyerId: String?, idfa: String?, bundleId: String?, numRetries: Int) {
        self.listingId = listingId
        self.transactionId = transactionId
        self.paymentId = paymentId
        self.receiptData = receiptData
        self.itemId = itemId
        self.itemPrice = itemPrice
        self.itemCurrency = itemCurrency
        self.amplitudeId = amplitudeId
        self.appsflyerId = appsflyerId
        self.idfa = idfa
        self.bundleId = bundleId
        self.numRetries = numRetries
    }

    init?(dictionary: [String:String?]) {
        guard let listingId = dictionary[FailedBumpInfo.listingIdKey] as? String else { return nil }
        guard let paymentId = dictionary[FailedBumpInfo.paymentIdKey] as? String else { return nil }
        guard let receiptData = dictionary[FailedBumpInfo.receiptDataKey] as? String else { return nil }
        guard let itemId = dictionary[FailedBumpInfo.itemIdKey] as? String else { return nil }
        guard let itemPrice = dictionary[FailedBumpInfo.itemPriceKey] as? String else { return nil }
        guard let itemCurrency = dictionary[FailedBumpInfo.itemCurrencyKey] as? String else { return nil }
        guard let numRetriesString = dictionary[FailedBumpInfo.numRetriesKey] as? String,
            let numRetries = Int(numRetriesString)
            else { return nil }

        let transactionId = dictionary[FailedBumpInfo.transactionIdKey] as? String

        let amplitudeId = dictionary[FailedBumpInfo.amplitudeIdKey] as? String
        let appsflyerId = dictionary[FailedBumpInfo.appsflyerIdKey] as? String
        let idfa = dictionary[FailedBumpInfo.idfaKey] as? String
        let bundleId = dictionary[FailedBumpInfo.bundleIdKey] as? String

        self.init(listingId: listingId,
                  transactionId: transactionId,
                  paymentId: paymentId,
                  receiptData: receiptData,
                  itemId: itemId,
                  itemPrice: itemPrice,
                  itemCurrency: itemCurrency,
                  amplitudeId: amplitudeId,
                  appsflyerId: appsflyerId,
                  idfa: idfa,
                  bundleId: bundleId,
                  numRetries: numRetries)
    }

    func dictionaryValue() -> [String:String?] {
        var dict: [String:String] = [:]
        dict[FailedBumpInfo.listingIdKey] = listingId
        dict[FailedBumpInfo.transactionIdKey] = transactionId
        dict[FailedBumpInfo.paymentIdKey] = paymentId
        dict[FailedBumpInfo.receiptDataKey] = receiptData
        dict[FailedBumpInfo.itemIdKey] = itemId
        dict[FailedBumpInfo.itemPriceKey] = itemPrice
        dict[FailedBumpInfo.itemCurrencyKey] = itemCurrency
        dict[FailedBumpInfo.amplitudeIdKey] = amplitudeId
        dict[FailedBumpInfo.appsflyerIdKey] = appsflyerId
        dict[FailedBumpInfo.idfaKey] = idfa
        dict[FailedBumpInfo.bundleIdKey] = bundleId
        dict[FailedBumpInfo.numRetriesKey] = String(numRetries)
        return dict
    }

    func updatingNumRetries(newNumRetries: Int) -> FailedBumpInfo {
        return FailedBumpInfo(listingId: listingId, transactionId: transactionId,
                              paymentId: paymentId, receiptData: receiptData, itemId: itemId,
                              itemPrice: itemPrice, itemCurrency: itemCurrency, amplitudeId: amplitudeId,
                              appsflyerId: appsflyerId, idfa: idfa, bundleId: bundleId, numRetries: newNumRetries)
    }
}
