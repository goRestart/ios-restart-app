//
//  PostListingTrackingInfo.swift
//  LetGo
//
//  Created by Eli Kohen on 10/04/2017.
//  Copyright © 2018 Ambatana B.V. Holdings. All rights reserved.
//

public struct PostListingTrackingInfo {
    var buttonName: EventParameterButtonNameType
    var sellButtonPosition: EventParameterSellButtonPosition
    var imageSource: EventParameterPictureSource
    var negotiablePrice: EventParameterNegotiablePrice
    var typePage: EventParameterTypePage
    var mostSearchedButton: EventParameterMostSearched
    var machineLearningInfo: MachineLearningTrackingInfo

    public init(buttonName: EventParameterButtonNameType,
                sellButtonPosition: EventParameterSellButtonPosition,
                imageSource: EventParameterPictureSource?,
                price: String?,
                typePage: EventParameterTypePage,
                mostSearchedButton: EventParameterMostSearched,
                machineLearningInfo: MachineLearningTrackingInfo) {
        self.buttonName = buttonName
        self.sellButtonPosition = sellButtonPosition
        self.imageSource = imageSource ?? .camera
        self.typePage = typePage
        self.mostSearchedButton = mostSearchedButton
        if let price = price, let doublePrice = Double(price) {
            negotiablePrice = doublePrice > 0 ? .no : .yes
        } else {
            negotiablePrice = .yes
        }
        self.machineLearningInfo = machineLearningInfo
    }
}
