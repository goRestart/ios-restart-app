//
//  PassiveBuyersDataSource.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 21/12/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

typealias PassiveBuyersDataSourceResult = Result<PassiveBuyersInfo, ApiError>
typealias PassiveBuyersDataSourceCompletion = PassiveBuyersDataSourceResult -> Void

typealias PassiveBuyersDataSourceEmptyResult = Result<Void, ApiError>
typealias PassiveBuyersDataSourceEmptyCompletion = PassiveBuyersDataSourceEmptyResult -> Void

protocol PassiveBuyersDataSource {
    func show(productId productId: String, completion: PassiveBuyersDataSourceCompletion?)
    func contact(productId productId: String, buyerIds: [String], completion: PassiveBuyersDataSourceEmptyCompletion?)
}
