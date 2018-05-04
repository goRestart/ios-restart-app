//
//  SearchAlertsRepository.swift
//  LGCoreKit
//
//  Created by Raúl de Oñate Blanco on 05/04/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

import Result

public typealias SearchAlertsEmptyResult = Result<Void, RepositoryError>
public typealias SearchAlertsEmptyCompletion = (SearchAlertsEmptyResult) -> Void

public typealias SearchAlertsIndexResult = Result<[SearchAlert], RepositoryError>
public typealias SearchAlertsIndexCompletion = (SearchAlertsIndexResult) -> Void

public typealias SearchAlertsCreateResult = Result<SearchAlertCreationData, RepositoryError>
public typealias SearchAlertsCreateCompletion = (SearchAlertsCreateResult) -> Void

public protocol SearchAlertsRepository {
    func create(query: String, completion: SearchAlertsCreateCompletion?)
    func index(limit: Int, offset: Int, completion: SearchAlertsIndexCompletion?)
    func enable(searchAlertId: String, completion: SearchAlertsEmptyCompletion?)
    func disable(searchAlertId: String, completion: SearchAlertsEmptyCompletion?)
    func delete(searchAlertId: String, completion: SearchAlertsEmptyCompletion?)
}
