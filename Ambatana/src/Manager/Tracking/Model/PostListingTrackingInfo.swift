//
//  PostListingTrackingInfo.swift
//  LetGo
//
//  Created by Eli Kohen on 10/04/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

struct PostListingTrackingInfo {
    var buttonName: EventParameterButtonNameType
    var sellButtonPosition: EventParameterSellButtonPosition
    var imageSource: EventParameterPictureSource
    var videoLength: TimeInterval?
    var negotiablePrice: EventParameterNegotiablePrice
    var typePage: EventParameterTypePage
    var machineLearningInfo: MachineLearningTrackingInfo

    init(buttonName: EventParameterButtonNameType,
         sellButtonPosition: EventParameterSellButtonPosition,
         imageSource: EventParameterPictureSource?,
         videoLength: TimeInterval?,
         price: String?,
         typePage: EventParameterTypePage,
         machineLearningInfo: MachineLearningTrackingInfo) {
        self.buttonName = buttonName
        self.sellButtonPosition = sellButtonPosition
        self.imageSource = imageSource ?? .camera
        self.videoLength = videoLength
        self.typePage = typePage
        if let price = price, let doublePrice = Double(price) {
            negotiablePrice = doublePrice > 0 ? .no : .yes
        } else {
            negotiablePrice = .yes
        }
        self.machineLearningInfo = machineLearningInfo
    }
}
