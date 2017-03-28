//
//  LGCarsInfoRepository.swift
//  LGCoreKit
//
//  Created by Dídac on 21/03/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Result

final class LGCarsInfoRepository: CarsInfoRepository {

    let dataSource: CarsInfoDataSource


    // MARK: - Lifecycle

    init(dataSource: CarsInfoDataSource) {
        self.dataSource = dataSource
    }

    func retrieveCarsInfoFileForCountry(countryCode: String?, completion: CarsInfoCompletion?) {
        dataSource.index(countryCode: countryCode) { result in
            if let value = result.value {
                completion?(CarsInfoResult(value: value))
            } else if let error = result.error {
                completion?(CarsInfoResult(error: RepositoryError(apiError: error)))
            }
        }
    }
}
