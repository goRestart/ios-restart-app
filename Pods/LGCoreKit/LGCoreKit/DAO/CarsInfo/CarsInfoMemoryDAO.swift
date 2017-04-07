//
//  CarsInfoMemoryDAO.swift
//  LGCoreKit
//
//  Created by Dídac on 07/04/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Argo

class CarsInfoMemoryDAO: CarsInfoDAO {

    private var carsMakesWithModelsList: [CarsMakeWithModels] = []

    var carsMakesList: [CarsMake] {
        let carsMakes = carsMakesWithModelsList.map { LGCarsMake(makeId: $0.makeId, makeName: $0.makeName) }
        return carsMakes
    }

    func save(carsInfo: [CarsMakeWithModels]) {
        carsMakesWithModelsList = carsInfo
    }

    func modelsForMake(makeId: String) -> [CarsModel] {
        return carsMakesWithModelsList.first(where: { $0.makeId == makeId })?.models ?? []
    }

    func clean() {
        carsMakesWithModelsList = []
    }

    func loadFirstRunCacheIfNeeded(jsonURL: URL) {
        do {
            let data = try Data(contentsOf: jsonURL)
            let jsonCarsMakesList = try JSONSerialization.jsonObject(with: data, options: [])
            guard let carsMakeList = decoder(jsonCarsMakesList) else { return }
            save(carsInfo: carsMakeList)
        } catch let error {
            logMessage(.verbose, type: CoreLoggingOptions.database, message: "Failed to create first run memory cache: \(error)")
        }
    }

    private func decoder(_ object: Any) -> [CarsMakeWithModels]? {
        let apiCarsMakeList: [ApiCarsMake]? = decode(object)
        return apiCarsMakeList
    }
}
