//
//  MachineLearningTrackingInfo.swift
//  LGAnalytics
//
//  Created by Albert Hernández López on 29/03/2018.
//

import LGCoreKit

public struct MachineLearningTrackingInfo {
    let listingName: String?
    let listingPrice: Double?
    let listingCategory: ListingCategory?

    let predictedName: String?
    let predictedPrice: Double?
    let predictedCategory: ListingCategory?

    let predictiveFlow: Bool
    let predictionActive: Bool

    public init(listingName: String?,
                listingPrice: Double?,
                listingCategory: ListingCategory?,
                predictedName: String?,
                predictedPrice: Double?,
                predictedCategory: ListingCategory?,
                predictiveFlow: Bool,
                predictionActive: Bool) {
        self.listingName = listingName
        self.listingPrice = listingPrice
        self.listingCategory = listingCategory
        self.predictedName = predictedName
        self.predictedPrice = predictedPrice
        self.predictedCategory = predictedCategory
        self.predictiveFlow = predictiveFlow
        self.predictionActive = predictionActive
    }

    public static func makeDefault() -> MachineLearningTrackingInfo {
        return MachineLearningTrackingInfo(listingName: nil,
                                           listingPrice: nil,
                                           listingCategory: nil,
                                           predictedName: nil,
                                           predictedPrice: nil,
                                           predictedCategory: nil,
                                           predictiveFlow: false,
                                           predictionActive: false)
    }
}
