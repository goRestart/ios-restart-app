//
//  CommercializerDataSource.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 2/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

typealias CommercializersDataSourceResult = Result<[Commercializer], ApiError>
typealias CommercializersDataSourceCompletion = (CommercializersDataSourceResult) -> Void

protocol CommercializerDataSource {
    func index(_ productId: String, completion: CommercializersDataSourceCompletion?)
}
