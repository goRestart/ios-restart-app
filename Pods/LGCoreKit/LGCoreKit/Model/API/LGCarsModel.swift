//
//  LGCarsModel.swift
//  LGCoreKit
//
//  Created by Dídac on 05/04/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

class LGCarsModel: CarsModel {
    var modelId: String
    var modelName: String

    init(modelId: String, modelName: String) {
        self.modelId = modelId
        self.modelName = modelName
    }
}
