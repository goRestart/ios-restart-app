//
//  SearchAlertsApiDataSource.swift
//  LGCoreKit
//
//  Created by Raúl de Oñate Blanco on 05/04/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

import Foundation

final class SearchAlertsApiDataSource: SearchAlertsDataSource {
    
    let apiClient: ApiClient
    
    
    // MARK: - Lifecycle
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    
    // MARK: - Requests
    
    func create(withParams params: SearchAlertCreateParams, completion: SearchAlertsEmptyDataSourceCompletion?) {
        let request = SearchAlertsRouter.create(params: params.apiParams)
        apiClient.request(request, completion: completion)
    }
    
    func index(limit: Int, offset: Int, completion: SearchAlertsIndexDataSourceCompletion?) {
        let request = SearchAlertsRouter.index(params: ["limit" : limit, "offset" : offset])
        apiClient.request(request, decoder: SearchAlertsApiDataSource.decoder, completion: completion)
    }
    
    func enable(searchAlertId: String, completion: SearchAlertsEmptyDataSourceCompletion?) {
        let request = SearchAlertsRouter.enable(searchAlertId: searchAlertId)
        apiClient.request(request, completion: completion)
    }
    
    func disable(searchAlertId: String, completion: SearchAlertsEmptyDataSourceCompletion?) {
        let request = SearchAlertsRouter.disable(searchAlertId: searchAlertId)
        apiClient.request(request, completion: completion)
    }
    
    func delete(searchAlertId: String, completion: SearchAlertsEmptyDataSourceCompletion?) {
        let request = SearchAlertsRouter.delete(searchAlertId: searchAlertId)
        apiClient.request(request, completion: completion)
    }
    
    
    // MARK: - Decoder
    
    private static func decoder(_ object: Any) -> [SearchAlert]? {
        guard let dict = object as? [String : [String : [[String : Any]]]] else { return nil }
        guard let searchAlertsDict = dict["data"]?["search_alerts"] else { return nil }
        guard let searchAlertsData = try? JSONSerialization.data(withJSONObject: searchAlertsDict, options: .prettyPrinted) else { return nil }
        do {
            let searchAlerts = try JSONDecoder().decode(FailableDecodableArray<LGSearchAlert>.self, from: searchAlertsData)
            return searchAlerts.validElements
        } catch {
            logAndReportParseError(object: object, entity: .searchAlerts,
                                   comment: "could not parse [SearchAlert]")
        }
        return nil
    }
}

