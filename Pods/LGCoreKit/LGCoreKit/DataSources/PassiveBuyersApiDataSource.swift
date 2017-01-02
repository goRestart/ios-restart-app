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

    func show(productId productId: String, completion: PassiveBuyersDataSourceCompletion?) {
        let request = PassiveBuyersRouter.Show(productId: productId)
        apiClient.request(request, decoder: decoder, completion: completion)
    }

    func contact(productId productId: String, buyerIds: [String], completion: PassiveBuyersDataSourceEmptyCompletion?) {
        let params: [String: AnyObject] = ["buyers": buyerIds]
        let request = PassiveBuyersRouter.CreateContacts(productId: productId, params: params)
        apiClient.request(request, completion: completion)
    }
}


// MARK: - Private
// MARK: > Decoders

private extension PassiveBuyersApiDataSource {
    func decoder(object: AnyObject) -> PassiveBuyersInfo? {
        let passiveBuyersInfo: LGPassiveBuyersInfo? = decode(object)
        return passiveBuyersInfo
    }
}
