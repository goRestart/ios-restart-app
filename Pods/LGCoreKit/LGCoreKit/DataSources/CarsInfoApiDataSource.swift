//
//  CarsInfoAPIDataSource.swift
//  LGCoreKit
//
//  Created by Dídac on 21/03/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Argo


class CarsInfoApiDataSource: CarsInfoDataSource {

    let apiClient: ApiClient


    // MARK: - Lifecycle

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }


    // MARK: - Public Methods
    
    func index(countryCode: String?, completion: CarsInfoDataSourceCompletion?) {
        var params: [String : Any] = [:]
        if let countryCode = countryCode {
            params["country_code"] = countryCode
        }
        let request = CarsInfoRouter.index(params: params)
        apiClient.request(request, decoder: decoder, completion: completion)
    }


    // MARK: - Decoder

    private func decoder(_ object: Any) -> [CarsMakeWithModels]? {
        let apiCarsMakeList: [ApiCarsMake]? = decode(object)
        return apiCarsMakeList
    }
}
