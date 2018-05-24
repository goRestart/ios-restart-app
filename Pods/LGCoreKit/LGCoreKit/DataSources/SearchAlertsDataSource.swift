//
//  SearchAlertsDataSource.swift
//  LGCoreKit
//
//  Created by Raúl de Oñate Blanco on 05/04/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

import Result

typealias SearchAlertsEmptyDataSourceResult = Result<Void, ApiError>
typealias SearchAlertsEmptyDataSourceCompletion = (SearchAlertsEmptyDataSourceResult) -> Void

typealias SearchAlertsIndexDataSourceResult = Result<[SearchAlert], ApiError>
typealias SearchAlertsIndexDataSourceCompletion = (SearchAlertsIndexDataSourceResult) -> Void

protocol SearchAlertsDataSource {
    func create(withParams params: SearchAlertCreateParams, completion: SearchAlertsEmptyDataSourceCompletion?)
    func index(limit: Int, offset: Int, completion: SearchAlertsIndexDataSourceCompletion?)
    func enable(searchAlertId: String, completion: SearchAlertsEmptyDataSourceCompletion?)
    func disable(searchAlertId: String, completion: SearchAlertsEmptyDataSourceCompletion?)
    func delete(searchAlertId: String, completion: SearchAlertsEmptyDataSourceCompletion?)
}
