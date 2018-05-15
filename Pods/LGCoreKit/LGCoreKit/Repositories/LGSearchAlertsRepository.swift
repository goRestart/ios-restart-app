//
//  LGSearchAlertsRepository.swift
//  LGCoreKit
//
//  Created by Raúl de Oñate Blanco on 05/04/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

final class LGSearchAlertsRepository: SearchAlertsRepository {
    
    private let dataSource: SearchAlertsDataSource
    private let locationManager: LocationManager
    
    
    // MARK: - Lifecycle
    
    init(dataSource: SearchAlertsDataSource, locationManager: LocationManager) {
        self.dataSource = dataSource
        self.locationManager = locationManager
    }
    
    
    // MARK: - Requests
    
    func create(query: String, completion: SearchAlertsCreateCompletion?) {
        guard let latitude = locationManager.currentLocation?.location.latitude else { return }
        guard let longitude = locationManager.currentLocation?.location.longitude else { return }
        let uuid = LGUUID().UUIDString
        let createdAt = Date().roundedMillisecondsSince1970()
        let params = SearchAlertCreateParams(objectId: uuid,
                                             query: query,
                                             latitude: latitude,
                                             longitude: longitude,
                                             createdAt: createdAt)
        dataSource.create(withParams: params) { result in
            if result.value != nil {
                let searchAlertCreationData = SearchAlertCreationData(objectId: uuid,
                                                                      query: query,
                                                                      isCreated: true,
                                                                      isEnabled: true)
                completion?(SearchAlertsCreateResult(value: searchAlertCreationData))
            } else if let error = result.error {
                let repositoryError = RepositoryError(apiError: error)
                completion?(SearchAlertsCreateResult(error: repositoryError))
            }
        }
    }
    
    func index(limit: Int, offset: Int, completion: SearchAlertsIndexCompletion?) {
        dataSource.index(limit: limit, offset: offset) { result in
            handleApiResult(result, completion: completion)
        }
    }
    
    func enable(searchAlertId: String, completion: SearchAlertsEmptyCompletion?) {
        dataSource.enable(searchAlertId: searchAlertId) { result in
            handleApiResult(result, completion: completion)
        }
    }
    
    func disable(searchAlertId: String, completion: SearchAlertsEmptyCompletion?) {
        dataSource.disable(searchAlertId: searchAlertId) { result in
            handleApiResult(result, completion: completion)
        }
    }
    
    func delete(searchAlertId: String, completion: SearchAlertsEmptyCompletion?)  {
        dataSource.delete(searchAlertId: searchAlertId) { result in
            handleApiResult(result, completion: completion)
        }
    }
}

