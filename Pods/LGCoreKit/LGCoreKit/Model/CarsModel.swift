//
//  CarsModel.swift
//  LGCoreKit
//
//  Created by Dídac on 21/03/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

public protocol CarsModel {
    var modelId: String { get }
    var modelName: String { get }
}

public extension CarsModel {
    func years(firstYear: Int?) -> [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        guard let actualFirstYear = firstYear else {
            return Array(LGCoreKitConstants.carsFirstYear...currentYear)
        }
        // older cars than 1900? unlikely... :/
        var modelFirstYear = max(LGCoreKitConstants.carsFirstYear, actualFirstYear)
        // let's make sure the first year is smaller than the current year
        modelFirstYear = min(modelFirstYear, currentYear)
        return Array(modelFirstYear...currentYear)
    }
}
