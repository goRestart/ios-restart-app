//
//  SearchesApiDataSource.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 06/06/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo

class TrendingSearchesApiDataSource: TrendingSearchesDataSource {

    let apiClient: ApiClient


    // MARK: - Lifecycle

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }


    // MARK: - Actions

    func index(countryCode: String, completion: TrendingSearchesDataSourceCompletion?) {
        let request = TrendingSearchesRouter.Index(params: ["country_code" : countryCode])
        apiClient.request(request, decoder: TrendingSearchesApiDataSource.decoder, completion: completion)
    }


    // MARK: - Decoders

    private static func decoder(object: AnyObject) -> [String]? {
        return decode(object)
    }
}

