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

    static private var allTests: [ABVariable] {
        return [bigFavoriteIcon, showRelatedProducts, showPriceOnListings, directStickersOnProduct, postingDetailsMode]
    }

    static func registerVariables() {
        allTests.forEach { $0.register() }
    }

    static func variablesUpdated() {
        let result = allTests.flatMap{ $0.trackingData }
        trackingData.value = result
    }
}
