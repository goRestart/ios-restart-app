//
//  CarsInfoRepository.swift
//  LGCoreKit
//
//  Created by Dídac on 21/03/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Result

public protocol CarsInfoRepository {
    func loadFirstRunCacheIfNeeded(jsonURL: URL)
    func refreshCarsInfoFile()
    func retrieveCarsMakes() -> [CarsMake]
    func retrieveCarsModelsFormake(makeId: String) -> [CarsModel]
    func retrieveValidYears(withFirstYear firstYear: Int?, ascending: Bool) -> [Int]
    func retrieveModelName(with makeId: String?, modelId: String?) -> String?
    func retrieveMakeName(with makeId: String?) -> String?
}
