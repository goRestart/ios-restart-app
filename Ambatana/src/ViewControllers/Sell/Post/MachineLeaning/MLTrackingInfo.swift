//
//  MLTrackingInfo.swift
//  LetGo
//
//  Created by Nestor on 15/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit

struct MachineLearningTrackingInfo {
    var data: MLPredictionDetailsViewData?
    var predictiveFlow: Bool
    var predictionActive: Bool
    
    var productName: String? {
        return data?.title
    }
    var productPrice: Double? {
        return data?.price
    }
    var productCategory: ListingCategory? {
        return data?.category
    }
    
    var predictedName: String? {
        return data?.predictedTitle
    }
    var predictedPrice: Double? {
        return data?.predictedPrice
    }
    var predictedCategory: ListingCategory? {
        return data?.predictedCategory
    }
    
    static func defaultValues() -> MachineLearningTrackingInfo {
        return MachineLearningTrackingInfo(data: nil, predictiveFlow: false, predictionActive: false)
    }
}
