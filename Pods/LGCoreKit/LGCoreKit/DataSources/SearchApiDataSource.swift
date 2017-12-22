//
//  SearchApiDataSource.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 06/06/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation

class SearchApiDataSource: SearchDataSource {

    let apiClient: ApiClient


    // MARK: - Lifecycle

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }


    // MARK: - Actions

    func index(countryCode: String, completion: TrendingSearchesDataSourceCompletion?) {
        let request = SearchRouter.index(params: ["country_code" : countryCode])
        apiClient.request(request, decoder: SearchApiDataSource.decoder, completion: completion)
    }

    func retrieveSuggestiveSearches(language: String,
                                    limit: Int,
                                    term: String,
                                    shouldIncludeCategories: Bool,
                                    completion: SuggestiveSearchesDataSourceCompletion?) {
        let request = SearchRouter.retrieveSuggestiveSearches(params: ["language" : language, "limit" : limit, "term" : term],
                                                              shouldIncludeCategories: shouldIncludeCategories)
        apiClient.request(request, decoder: SearchApiDataSource.decoderSuggestiveResult, completion: completion)
    }

    // MARK: - Decoders

    private static func decoder(_ object: Any) -> [String]? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else { return nil }
        do {
            let strings = try [String].decode(jsonData: data)
            return strings
        } catch {
            logMessage(.debug, type: .parsing, message: "could not parse Strings \(object)")
        }
        return nil
    }
    
    private static func decoderSuggestiveResult(_ object: Any) -> [SuggestiveSearch]? {
        guard let dict = object as? [String : Any] else { return nil }
        guard let itemsArray = dict["items"] as? [[String : Any]] else { return nil }
        guard let data = try? JSONSerialization.data(withJSONObject: itemsArray, options: .prettyPrinted) else { return nil }

        // Ignore suggestive searches that can't be decoded
        do {
            let suggestiveSearches = try JSONDecoder().decode(FailableDecodableArray<SuggestiveSearch>.self, from: data)
            return suggestiveSearches.validElements
        } catch {
            logMessage(.debug, type: .parsing, message: "could not parse SuggestiveResult \(object)")
        }
        return nil
    }
}


