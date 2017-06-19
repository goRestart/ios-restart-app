//
//  CarsInfoDataSource.swift
//  LGCoreKit
//
//  Created by Dídac on 21/03/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Result

typealias CarsInfoDataSourceResult = Result<[CarsMakeWithModels], ApiError>
typealias CarsInfoDataSourceCompletion = (CarsInfoDataSourceResult) -> Void

protocol CarsInfoDataSource {
    func index(countryCode: String?, completion: CarsInfoDataSourceCompletion?)
}
