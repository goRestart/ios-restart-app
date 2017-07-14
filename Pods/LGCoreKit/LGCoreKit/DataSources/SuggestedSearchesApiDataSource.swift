//
//  SuggestedSearchesApiDataSource.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 06/06/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation
import Argo

class SuggestedSearchesApiDataSource: SuggestedSearchesDataSource {

    let apiClient: ApiClient


    // MARK: - Lifecycle

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }


    // MARK: - Actions

    func index(_ countryCode: String, completion: SuggestedSearchesDataSourceCompletion?) {
        let request = SuggestedSearchesRouter.index(params: ["country_code" : countryCode])
        apiClient.request(request, decoder: SuggestedSearchesApiDataSource.decoder, completion: completion)
    }

    func retrieveSuggestiveSearches(_ countryCode: String, limit: Int, term: String, completion: SuggestiveSearchesDataSourceCompletion?) {
        let request = SuggestedSearchesRouter.retrieveSuggestiveSearches(params: ["country_code" : countryCode, "limit" : limit, "term" : term])
        apiClient.request(request, decoder: SuggestedSearchesApiDataSource.decoderSuggestiveResult, completion: completion)
    }

    // MARK: - Decoders

    private static func decoder(_ object: Any) -> [String]? {
        return decode(object)
    }
    
    private static func decoderSuggestiveResult(_ object: Any) -> [SuggestiveSearch]? {
        guard let dict = object as? [String : Any] else { return nil }
        guard let itemsArray = dict["items"] else { return nil }
        
        guard let suggestiveSearches: [LGSuggestiveSearch]? = decode(itemsArray) else { return nil }
        return suggestiveSearches
    }
    
    private static func decoderArray(_ object: Any) -> [Commercializer]? {
        guard let dict = object as? [String : Any] else { return nil }
        guard let videosArray = dict["videos"] else { return nil }
        
        guard let theCommercializer : [LGCommercializer] = decode(videosArray) else { return nil }
        return theCommercializer.map{$0}
    }
    
    
}

