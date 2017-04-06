//
//  CarsInfoRepository.swift
//  LGCoreKit
//
//  Created by Dídac on 21/03/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Result

public typealias CarsMakesResult = Result<[CarsMake], RepositoryError>
public typealias CarsMakesCompletion = (CarsMakesResult) -> Void


public protocol CarsInfoRepository {
    func loadFirstRunCacheIfNeeded(jsonURL: URL?)
    func refreshCarsInfoFile()
    func retrieveCarsMakes() -> [CarsMake]
    func retrieveCarsModelsFormake(makeId: String) -> [CarsModel]
}
