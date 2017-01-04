//
//  PassiveBuyersApiDataSource.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 21/12/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Result

class PassiveBuyersApiDataSource: PassiveBuyersDataSource {
    let apiClient: ApiClient


    // MARK: - Lifecycle

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }


    // MARK: - PassiveBuyersDataSource

    func show(productId: String, completion: PassiveBuyersDataSourceCompletion?) {
        let request = PassiveBuyersRouter.show(productId: productId)
        apiClient.request(request, decoder: decoder, completion: completion)
    }

    func contact(productId: String, buyerIds: [String], completion: PassiveBuyersDataSourceEmptyCompletion?) {
        let params: [String: Any] = ["buyers": buyerIds]
        let request = PassiveBuyersRouter.createContacts(productId: productId, params: params)
        apiClient.request(request, completion: completion)
    }
}


// MARK: - Private
// MARK: > Decoders

private extension PassiveBuyersApiDataSource {
    func decoder(_ object: Any) -> PassiveBuyersInfo? {
        let passiveBuyersInfo: LGPassiveBuyersInfo? = decode(object)
        return passiveBuyersInfo
    }
}
