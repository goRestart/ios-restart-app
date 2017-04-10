//
//  PostProductTrackingInfo.swift
//  LetGo
//
//  Created by Eli Kohen on 10/04/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

struct PostProductTrackingInfo {
    var buttonName: EventParameterButtonNameType
    var sellButtonPosition: EventParameterSellButtonPosition
    var imageSource: EventParameterPictureSource
    var negotiablePrice: EventParameterNegotiablePrice

    init(buttonName: EventParameterButtonNameType, sellButtonPosition: EventParameterSellButtonPosition,
         imageSource: EventParameterPictureSource?, price: String?) {
        self.buttonName = buttonName
        self.sellButtonPosition = sellButtonPosition
        self.imageSource = imageSource ?? .camera
        if let price = price, let doublePrice = Double(price) {
            negotiablePrice = doublePrice > 0 ? .no : .yes
        } else {
            negotiablePrice = .yes
        }
    }
}
