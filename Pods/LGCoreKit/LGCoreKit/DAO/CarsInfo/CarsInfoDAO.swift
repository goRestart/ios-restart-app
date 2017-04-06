//
//  CarsInfoDAO.swift
//  LGCoreKit
//
//  Created by Dídac on 24/03/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

protocol CarsInfoDAO {
    var carsMakesList: [CarsMake] { get }
    func save(carsInfo: [CarsMakeWithModels])
    func modelsForMake(makeId: String) -> [CarsModel]
    func clean()
    func loadFirstRunCacheIfNeeded(jsonURL: URL?)
}
