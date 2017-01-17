//
//  ProductDataSource.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 8/1/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation
import Result

typealias ProductsDataSourceCompletion = (Result<[Product], ApiError>) -> Void

typealias ProductDataSourceCompletion = (Result<Product, ApiError>) -> Void
typealias ProductDataSourceEmptyCompletion = (Result<Void, ApiError>) -> Void

typealias ProductDataSourceUserRelationResult = Result<UserProductRelation, ApiError>
typealias ProductDataSourceUserRelationCompletion = (ProductDataSourceUserRelationResult) -> Void

typealias ProductDataSourceProductStatsResult = Result<ProductStats, ApiError>
typealias ProductDataSourceProductStatsCompletion = (ProductDataSourceProductStatsResult) -> Void

protocol ProductDataSource {
    func index(_ parameters: [String: Any], completion: ProductsDataSourceCompletion?)
    func indexForUser(_ userId: String, parameters: [String: Any], completion: ProductsDataSourceCompletion?)
    func indexFavorites(_ userId: String, completion: ProductsDataSourceCompletion?)
    func indexRelatedProducts(_ productId: String, parameters: [String: Any], completion: ProductsDataSourceCompletion?)
    func indexDiscoverProducts(_ productId: String, parameters: [String: Any], completion: ProductsDataSourceCompletion?)
    func retrieve(_ productId: String, completion: ProductDataSourceCompletion?)
    func create(_ product: [String: Any], completion: ProductDataSourceCompletion?)
    func update(_ productId: String, product: [String: Any], completion: ProductDataSourceCompletion?)
    func markAs(sold: Bool, productId: String, completion: ProductDataSourceEmptyCompletion?)
    func delete(_ productId: String, completion: ProductDataSourceEmptyCompletion?)
    func deleteFavorite(_ productId: String, userId: String, completion: ProductDataSourceEmptyCompletion?)
    func saveFavorite(_ productId: String, userId: String, completion: ProductDataSourceEmptyCompletion?)
    func retrieveRelation(_ productId: String, userId: String, completion: ProductDataSourceUserRelationCompletion?)
    func saveReport(_ productId: String, userId: String, completion: ProductDataSourceEmptyCompletion?)
    func indexLimbo(_ productIds: [String], completion: ProductsDataSourceCompletion?)
    func indexTrending(_ parameters: [String: Any], completion: ProductsDataSourceCompletion?)
    func retrieveStats(_ productId: String, completion: ProductDataSourceProductStatsCompletion?)
    func updateStats(_ productIds: [String], action: String, completion: ProductDataSourceEmptyCompletion?)
}
