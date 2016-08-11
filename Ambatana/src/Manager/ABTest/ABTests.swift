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

    static func registerVariables() {
        let _ = bigFavoriteIcon.value
        let _ = showRelatedProducts.value
        let _ = showPriceOnListings.value
    }

    static func variablesUpdated() {
        var result: [(String, AnyObject)] = []
        if let bigFavoriteIconData = bigFavoriteIcon.trackingData {
            result.append(bigFavoriteIconData)
        }
        if let relatedProductsData = showRelatedProducts.trackingData {
            result.append(relatedProductsData)
        }
        if let priceOnListingsData = showPriceOnListings.trackingData {
            result.append(priceOnListingsData)
        }
        trackingData.value = result
    }
}
