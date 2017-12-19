//
//  CarsInfoMemoryDAO.swift
//  LGCoreKit
//
//  Created by Dídac on 07/04/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

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
        guard carsMakesWithModelsList.isEmpty else { return }
        do {
            let data = try Data(contentsOf: jsonURL)
            let jsonCarsMakesList = try JSONSerialization.jsonObject(with: data, options: [])
            guard let carsMakeList = decoder(jsonCarsMakesList) else { return }
            save(carsInfo: carsMakeList)
        } catch let error {
            logMessage(.verbose, type: CoreLoggingOptions.database, message: "Failed to create Cars Info first run memory cache: \(error)")
        }
    }

    func retrieveMakeName(with makeId: String?) -> String? {
        return carsMakesWithModelsList.first(where: { $0.makeId == makeId })?.makeName
    }
    
    func retrieveModelName(with makeId: String?, modelId: String?) -> String? {
        guard let makeId = makeId else { return nil }
        guard let modelId = modelId else { return nil }
        let models = modelsForMake(makeId: makeId)
        return models.first(where: { $0.modelId == modelId })?.modelName
    }
    
    private func decoder(_ object: Any) -> [CarsMakeWithModels]? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else { return nil }
        
        // Ignore cars makes with model that can't be decoded
        do {
            let apiCarsMake = try JSONDecoder().decode(FailableDecodableArray<ApiCarsMake>.self, from: data)
            return apiCarsMake.validElements
        } catch {
            logMessage(.debug, type: .parsing, message: "could not parse ApiCarsMake \(object)")
        }
        return nil
    }
}
