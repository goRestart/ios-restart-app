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

    static var bigFavoriteIcon = BoolABDynamicVar(key: "bigFavoriteIcon", defaultValue: false)
    static var showRelatedProducts = BoolABDynamicVar(key: "showRelatedProducts", defaultValue: false)
    static var showPriceOnListings = BoolABDynamicVar(key: "showPriceOnListings", defaultValue: false)
    static var directStickersOnProduct = BoolABDynamicVar(key: "directStickersOnProduct", defaultValue: false)
    static var postingDetailsMode = IntABDynamicVar(key: "postingDetailsMode", defaultValue: 0)

    static func registerVariables() {
        let _ = bigFavoriteIcon.value
        let _ = showRelatedProducts.value
        let _ = showPriceOnListings.value
        let _ = directStickersOnProduct.value
        let _ = postingDetailsMode.value
    }

    static func variablesUpdated() {
        let allBoolVars = [bigFavoriteIcon, showRelatedProducts, showPriceOnListings, directStickersOnProduct]
        let allIntVars = [postingDetailsMode]
        let result = allBoolVars.flatMap{ $0.trackingData } + allIntVars.flatMap{ $0.trackingData }
        trackingData.value = result
    }
}
