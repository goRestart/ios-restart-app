//
//  ProductApiDataSource.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 8/1/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation
import Argo
import Result

final class ProductApiDataSource: ProductDataSource {
    let apiClient: ApiClient
    
    
    // MARK: - Lifecycle
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    
    // MARK: Product CRUD
    
    func index(_ parameters: [String: Any], completion: ProductsDataSourceCompletion?) {
        let request = ProductRouter.index(params: parameters)
        apiClient.request(request, decoder: ProductApiDataSource.decoderArray, completion: completion)
    }
    
    func indexForUser(_ userId: String, parameters: [String: Any], completion: ProductsDataSourceCompletion?) {
        let request = ProductRouter.indexForUser(userId: userId, params: parameters)
        apiClient.request(request, decoder: ProductApiDataSource.decoderArray, completion: completion)
    }
    
    func indexFavorites(_ userId: String, completion: ProductsDataSourceCompletion?) {
        let request = ProductRouter.indexFavorites(userId: userId)
        apiClient.request(request, decoder: ProductApiDataSource.decoderArray, completion: completion)
    }

    func indexRelatedProducts(_ productId: String, parameters: [String: Any], completion: ProductsDataSourceCompletion?) {
        let request = ProductRouter.indexRelatedProducts(productId: productId, params: parameters)
        apiClient.request(request, decoder: ProductApiDataSource.decoderArray, completion: completion)
    }

    func indexDiscoverProducts(_ productId: String, parameters: [String: Any], completion: ProductsDataSourceCompletion?) {
        let request = ProductRouter.indexDiscoverProducts(productId: productId, params: parameters)
        apiClient.request(request, decoder: ProductApiDataSource.decoderArray, completion: completion)
    }

    func retrieve(_ productId: String, completion: ProductDataSourceCompletion?) {
        let request = ProductRouter.show(productId: productId)
        apiClient.request(request, decoder: ProductApiDataSource.decoder, completion: completion)
    }
    
    func create(_ product: [String: Any], completion: ProductDataSourceCompletion?) {
        let request = ProductRouter.create(params: product)
        apiClient.request(request, decoder: ProductApiDataSource.decoder, completion: completion)
    }
    
    func update(_ productId: String, product: [String: Any], completion: ProductDataSourceCompletion?) {
        let request = ProductRouter.update(productId: productId, params: product)
        apiClient.request(request, decoder: ProductApiDataSource.decoder, completion: completion)
    }

    // MARK: Sold / unsold

    func markAsSold(_ productId: String, buyerId: String?, completion: ProductDataSourceEmptyCompletion?) {
        var params = [String: Any]()
        params["status"] = ProductStatus.sold.rawValue
        if let buyerId = buyerId {
            params["buyerUserId"] = buyerId
            params["soldIn"] = "letgo"
        } else {
            params["soldIn"] = "external"
        }
        let request = ProductRouter.patch(productId: productId, params: params)
        apiClient.request(request, completion: completion)
    }

    func markAsUnSold(_ productId: String, completion: ProductDataSourceEmptyCompletion?) {
        let params: [String: Any] = ["status": ProductStatus.approved.rawValue]
        let request = ProductRouter.patch(productId: productId, params: params)
        apiClient.request(request, completion: completion)
    }
    
    func delete(_ productId: String, completion: ProductDataSourceEmptyCompletion?) {
        let request = ProductRouter.delete(productId: productId)
        apiClient.request(request, completion: completion)
    }
    
    
    // MARK: Product-User relation
    
    func retrieveRelation(_ productId: String, userId: String, completion: ProductDataSourceUserRelationCompletion?) {
        let request = ProductRouter.userRelation(userId: userId, productId: productId) 
        apiClient.request(request, decoder: ProductApiDataSource.decoderUserRelation, completion: completion)
    }
    
    func saveReport(_ productId: String, userId: String, completion: ProductDataSourceEmptyCompletion?) {
        let request = ProductRouter.saveReport(userId: userId, productId: productId)
        apiClient.request(request, completion: completion)
    }
    
    
    // MARK: Favorites
    
    func deleteFavorite(_ productId: String, userId: String, completion: ProductDataSourceEmptyCompletion?) {
        let request = ProductRouter.deleteFavorite(userId: userId, productId: productId)
        apiClient.request(request, completion: completion)
    }
    
    func saveFavorite(_ productId: String, userId: String, completion: ProductDataSourceEmptyCompletion?) {
        let request = ProductRouter.saveFavorite(userId: userId, productId: productId)
        apiClient.request(request, completion: completion)
    }


    // MARK: Limbo

    func indexLimbo(_ productIds: [String], completion: ProductsDataSourceCompletion?) {
        let params: [String: Any] = ["ids": productIds]
        let request = ProductRouter.indexLimbo(params: params)
        apiClient.request(request, decoder: ProductApiDataSource.decoderArray, completion: completion)
    }

    // MARK: Trending

    func indexTrending(_ parameters: [String: Any], completion: ProductsDataSourceCompletion?) {
        let request = ProductRouter.indexTrending(params: parameters)
        apiClient.request(request, decoder: ProductApiDataSource.decoderArray, completion: completion)
    }

    // MARK: Stats

    func retrieveStats(_ productId: String, completion: ProductDataSourceProductStatsCompletion?) {
        let request = ProductRouter.showStats(productId: productId, params: [:])
        apiClient.request(request, decoder: ProductApiDataSource.decoderProductStats, completion: completion)
    }
    
    func updateStats(_ productIds: [String], action: String, completion: ProductDataSourceEmptyCompletion?) {
        let params : [String : Any] = ["productIds" : productIds, "action" : action]
        let request = ProductRouter.updateStats(params: params)
        apiClient.request(request, completion: completion)
    }

    // MARK: Possible buyers

    func possibleBuyersOf(productId: String, completion: ProductDataSourceUsersCompletion?) {
        let request = ProductRouter.possibleBuyers(productId: productId)
        apiClient.request(request, decoder: ProductApiDataSource.decoderUserArray, completion: completion)
    }

    // MARK: Decode products
    
    private static func decoderArray(_ object: Any) -> [Product]? {
        guard let theProduct : [LGProduct] = decode(object) else { return nil }
        return theProduct
    }
    
    private static func decoder(_ object: Any) -> Product? {
        let product: LGProduct? = decode(object)
        return product
    }
    
    static func decoderUserRelation(_ object: Any) -> UserProductRelation? {
        let relation: LGUserProductRelation? = decode(object)
        return relation
    }

    static func decoderProductStats(_ object: Any) -> ProductStats? {
        let stats: LGProductStats? = decode(object)
        return stats
    }

    private static func decoderUserArray(_ object: Any) -> [UserProduct]? {
        guard let theUsers : [LGUserProduct] = decode(object) else { return nil }
        return theUsers
    }
}
