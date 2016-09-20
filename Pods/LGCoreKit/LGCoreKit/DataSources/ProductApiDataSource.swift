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
    
    func index(parameters: [String: AnyObject], completion: ProductsDataSourceCompletion?) {
        let request = ProductRouter.Index(params: parameters)
        apiClient.request(request, decoder: ProductApiDataSource.decoderArray, completion: completion)
    }
    
    func indexForUser(userId: String, parameters: [String: AnyObject], completion: ProductsDataSourceCompletion?) {
        let request = ProductRouter.IndexForUser(userId: userId, params: parameters)
        apiClient.request(request, decoder: ProductApiDataSource.decoderArray, completion: completion)
    }
    
    func indexFavorites(userId: String, completion: ProductsDataSourceCompletion?) {
        let request = ProductRouter.IndexFavorites(userId: userId)
        apiClient.request(request, decoder: ProductApiDataSource.decoderArray, completion: completion)
    }

    func indexRelatedProducts(productId: String, parameters: [String: AnyObject], completion: ProductsDataSourceCompletion?) {
        let request = ProductRouter.IndexRelatedProducts(productId: productId, params: parameters)
        apiClient.request(request, decoder: ProductApiDataSource.decoderArray, completion: completion)
    }

    func indexDiscoverProducts(productId: String, parameters: [String: AnyObject], completion: ProductsDataSourceCompletion?) {
        let request = ProductRouter.IndexDiscoverProducts(productId: productId, params: parameters)
        apiClient.request(request, decoder: ProductApiDataSource.decoderArray, completion: completion)
    }

    func retrieve(productId: String, completion: ProductDataSourceCompletion?) {
        let request = ProductRouter.Show(productId: productId)
        apiClient.request(request, decoder: ProductApiDataSource.decoder, completion: completion)
    }
    
    func create(product: [String: AnyObject], completion: ProductDataSourceCompletion?) {
        let request = ProductRouter.Create(params: product)
        apiClient.request(request, decoder: ProductApiDataSource.decoder, completion: completion)
    }
    
    func update(productId: String, product: [String: AnyObject], completion: ProductDataSourceCompletion?) {
        let request = ProductRouter.Update(productId: productId, params: product)
        apiClient.request(request, decoder: ProductApiDataSource.decoder, completion: completion)
    }
    
    func markAs(sold sold: Bool, productId: String, completion: ProductDataSourceEmptyCompletion?) {
        let status = sold ? ProductStatus.Sold.rawValue : ProductStatus.Approved.rawValue
        let params: [String: AnyObject] = ["status": status]
        let request = ProductRouter.Patch(productId: productId, params: params)
        apiClient.request(request, completion: completion)
    }
    
    func delete(productId: String, completion: ProductDataSourceEmptyCompletion?) {
        let request = ProductRouter.Delete(productId: productId)
        apiClient.request(request, completion: completion)
    }
    
    
    // MARK: Product-User relation
    
    func retrieveRelation(productId: String, userId: String, completion: ProductDataSourceUserRelationCompletion?) {
        let request = ProductRouter.UserRelation(userId: userId, productId: productId) 
        apiClient.request(request, decoder: ProductApiDataSource.decoderUserRelation, completion: completion)
    }
    
    func saveReport(productId: String, userId: String, completion: ProductDataSourceEmptyCompletion?) {
        let request = ProductRouter.SaveReport(userId: userId, productId: productId)
        apiClient.request(request, completion: completion)
    }
    
    
    // MARK: Favorites
    
    func deleteFavorite(productId: String, userId: String, completion: ProductDataSourceEmptyCompletion?) {
        let request = ProductRouter.DeleteFavorite(userId: userId, productId: productId)
        apiClient.request(request, completion: completion)
    }
    
    func saveFavorite(productId: String, userId: String, completion: ProductDataSourceEmptyCompletion?) {
        let request = ProductRouter.SaveFavorite(userId: userId, productId: productId)
        apiClient.request(request, completion: completion)
    }


    // MARK: Limbo

    func indexLimbo(productIds: [String], completion: ProductsDataSourceCompletion?) {
        let params: [String: AnyObject] = ["ids": productIds]
        let request = ProductRouter.IndexLimbo(params: params)
        apiClient.request(request, decoder: ProductApiDataSource.decoderArray, completion: completion)
    }

    // MARK: Trending

    func indexTrending(parameters: [String: AnyObject], completion: ProductsDataSourceCompletion?) {
        let request = ProductRouter.IndexTrending(params: parameters)
        apiClient.request(request, decoder: ProductApiDataSource.decoderArray, completion: completion)
    }

    // MARK: Stats

    func retrieveStats(productId: String, completion: ProductDataSourceProductStatsCompletion?) {
        let request = ProductRouter.ShowStats(productId: productId, params: [:])
        apiClient.request(request, decoder: ProductApiDataSource.decoderProductStats, completion: completion)
    }
    
    func updateStats(productIds: [String], action: String, completion: ProductDataSourceEmptyCompletion?) {
        let params : [String : AnyObject] = ["productIds" : productIds,
                                             "action" : action]
        let request = ProductRouter.UpdateStats(params: params)
        apiClient.request(request, completion: completion)
    }

    // MARK: Decode products
    
    private static func decoderArray(object: AnyObject) -> [Product]? {
        guard let theProduct : [LGProduct] = decode(object) else { return nil }
        return theProduct.map{$0}
    }
    
    private static func decoder(object: AnyObject) -> Product? {
        let product: LGProduct? = decode(object)
        return product
    }
    
    static func decoderUserRelation(object: AnyObject) -> UserProductRelation? {
        let relation: LGUserProductRelation? = decode(object)
        return relation
    }

    static func decoderProductStats(object: AnyObject) -> ProductStats? {
        let stats: LGProductStats? = decode(object)
        return stats
    }
}
