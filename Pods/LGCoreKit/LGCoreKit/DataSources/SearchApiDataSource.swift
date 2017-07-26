//
//  SearchApiDataSource.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 06/06/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation
import Argo

class SearchApiDataSource: SearchDataSource {

    let apiClient: ApiClient


    // MARK: - Lifecycle

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }


    // MARK: - Actions

    func index(_ countryCode: String, completion: TrendingSearchesDataSourceCompletion?) {
        let request = SearchRouter.index(params: ["country_code" : countryCode])
        apiClient.request(request, decoder: SearchApiDataSource.decoder, completion: completion)
    }

    func retrieveSuggestiveSearches(_ language: String, limit: Int, term: String, completion: SuggestiveSearchesDataSourceCompletion?) {
        let request = SearchRouter.retrieveSuggestiveSearches(params: ["language" : language, "limit" : limit, "term" : term])
        apiClient.request(request, decoder: SearchApiDataSource.decoderSuggestiveResult, completion: completion)
    }

    // MARK: - Decoders

    private static func decoder(_ object: Any) -> [String]? {
        return decode(object)
    }
    
    private static func decoderSuggestiveResult(_ object: Any) -> [SuggestiveSearch]? {
        guard let dict = object as? [String : Any] else { return nil }
        guard let itemsArray = dict["items"] else { return nil }
        
        guard let suggestiveSearches: [LGSuggestiveSearch] = decode(itemsArray) else { return nil }
        return suggestiveSearches
    }
    
}

