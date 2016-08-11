//
//  ABTests.swift
//  LetGo
//
//  Created by Dídac on 12/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxSwift

public struct ABTests {

    static let trackingData = Variable<[(String, AnyObject)]>([])

    static var showRelatedProducts = BoolABDynamicVar(key: "showRelatedProducts", defaultValue: false)
    static var showPriceOnListings = BoolABDynamicVar(key: "showPriceOnListings", defaultValue: false)
    static var directStickersOnProduct = BoolABDynamicVar(key: "directStickersOnProduct", defaultValue: false)

    static func registerVariables() {
        let _ = showRelatedProducts.value
        let _ = showPriceOnListings.value
        let _ = directStickersOnProduct.value
    }

    static func variablesUpdated() {
        let allVars = [showRelatedProducts, showPriceOnListings, directStickersOnProduct]
        let result = allVars.flatMap{ $0.trackingData }
        trackingData.value = result
    }
}
