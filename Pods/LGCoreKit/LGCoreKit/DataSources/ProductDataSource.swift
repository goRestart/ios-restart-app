//
//  ProductDataSource.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 8/1/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation
import Result

typealias ProductsDataSourceCompletion = Result<[Product], ApiError> -> Void

typealias ProductDataSourceCompletion = Result<Product, ApiError> -> Void
typealias ProductDataSourceEmptyCompletion = Result<Void, ApiError> -> Void

typealias ProductDataSourceUserRelationResult = Result<UserProductRelation, ApiError>
typealias ProductDataSourceUserRelationCompletion = ProductDataSourceUserRelationResult -> Void

typealias ProductDataSourceProductStatsResult = Result<ProductStats, ApiError>
typealias ProductDataSourceProductStatsCompletion = ProductDataSourceProductStatsResult -> Void

protocol ProductDataSource {
    func index(parameters: [String: AnyObject], completion: ProductsDataSourceCompletion?)
    func indexForUser(userId: String, parameters: [String: AnyObject], completion: ProductsDataSourceCompletion?)
    func indexFavorites(userId: String, completion: ProductsDataSourceCompletion?)
    func indexRelatedProducts(productId: String, parameters: [String: AnyObject], completion: ProductsDataSourceCompletion?)
    func indexDiscoverProducts(productId: String, parameters: [String: AnyObject], completion: ProductsDataSourceCompletion?)
    func retrieve(productId: String, completion: ProductDataSourceCompletion?)
    func create(product: [String: AnyObject], completion: ProductDataSourceCompletion?)
    func update(productId: String, product: [String: AnyObject], completion: ProductDataSourceCompletion?)
    func markAs(sold sold: Bool, productId: String, completion: ProductDataSourceEmptyCompletion?)
    func delete(productId: String, completion: ProductDataSourceEmptyCompletion?)
    func deleteFavorite(productId: String, userId: String, completion: ProductDataSourceEmptyCompletion?)
    func saveFavorite(productId: String, userId: String, completion: ProductDataSourceEmptyCompletion?)
    func retrieveRelation(productId: String, userId: String, completion: ProductDataSourceUserRelationCompletion?)
    func saveReport(productId: String, userId: String, completion: ProductDataSourceEmptyCompletion?)
    func indexLimbo(productIds: [String], completion: ProductsDataSourceCompletion?)
    func indexTrending(parameters: [String: AnyObject], completion: ProductsDataSourceCompletion?)
    func retrieveStats(productId: String, completion: ProductDataSourceProductStatsCompletion?)
    func updateStats(productIds: [String], action: String, completion: ProductDataSourceEmptyCompletion?)
}
