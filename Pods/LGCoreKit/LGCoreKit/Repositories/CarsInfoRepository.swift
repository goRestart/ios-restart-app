//
//  CarsInfoRepository.swift
//  LGCoreKit
//
//  Created by Dídac on 21/03/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Result

public typealias CarsInfoResult = Result<CarsInfo, RepositoryError>
public typealias CarsInfoCompletion = (CarsInfoResult) -> Void


public protocol CarsInfoRepository {
    func retrieveCarsInfoFileForCountry(countryCode: String?, completion: CarsInfoCompletion?)
}
