//
//  MockMonetizationRepository.swift
//  LetGo
//
//  Created by Dídac on 23/01/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit


class MockMonetizationRepository: MonetizationRepository {

    var bumpResult: BumpResult?
    var bumpCompletion: BumpCompletion?


    func retrieveBumpeableProductInfo(productId: String, completion: BumpeableProductCompletion?) {
        
    }

    func freeBump(forProduct productId: String, itemId: String, completion: BumpCompletion?) {
        performAfterDelayWithCompletion(completion, result: bumpResult)
    }

    func pricedBump(forProduct productId: String, receiptData: String, itemId: String, completion: BumpCompletion?) {
        performAfterDelayWithCompletion(completion, result: bumpResult)
    }
}
