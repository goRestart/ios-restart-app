//
//  ProductRepository.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 8/1/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

public typealias ProductStatsResult = Result<ProductStats, RepositoryError>
public typealias ProductStatsCompletion = ProductStatsResult -> Void

public typealias ProductUserRelationResult = Result<UserProductRelation, RepositoryError>
public typealias ProductUserRelationCompletion = ProductUserRelationResult -> Void

public typealias ProductResult = Result<Product, RepositoryError>
public typealias ProductCompletion = ProductResult -> Void

public typealias ProductVoidResult = Result<Void, RepositoryError>
public typealias ProductVoidCompletion = ProductVoidResult -> Void

public typealias ProductsResult = Result<[Product], RepositoryError>
public typealias ProductsCompletion = ProductsResult -> Void


public protocol ProductRepository {

    func buildNewProduct(name: String?, description: String?, price: ProductPrice, category: ProductCategory) -> Product?

    func updateProduct(product: Product, name: String?, description: String?, price: ProductPrice,
                              currency: Currency, location: LGLocationCoordinates2D?, postalAddress: PostalAddress?,
                              category: ProductCategory) -> Product

    
    // MARK: - Product CRUD
    
    func index(params: RetrieveProductsParams, completion: ProductsCompletion?)

    func index(userId userId: String, params: RetrieveProductsParams, completion: ProductsCompletion?)

    func indexRelated(productId productId: String, params: RetrieveProductsParams, completion: ProductsCompletion?)

    func indexDiscover(productId productId: String, params: RetrieveProductsParams, completion: ProductsCompletion?)
    
    func indexFavorites(userId: String, completion: ProductsCompletion?)
    
    func retrieve(productId: String, completion: ProductCompletion?)
    
    func create(product: Product, images: [UIImage], progress: (Float -> Void)?, completion: ProductCompletion?)
    
    func create(product: Product, images: [File], completion: ProductCompletion?)
    
    func update(product: Product, images: [UIImage], progress: (Float -> Void)?, completion: ProductCompletion?)
    
    func update(product: Product, oldImages: [File], newImages: [UIImage], progress: (Float -> Void)?, completion: ProductCompletion?)
    
    func update(product: Product, images: [File], completion: ProductCompletion?)
   
    func delete(product: Product, completion: ProductCompletion?)
    
    
    // MARK: - Mark product as (un)sold
    
    func markProductAsSold(productId: String, completion: ProductVoidCompletion?)

    func markProductAsSold(product: Product, completion: ProductCompletion?)
    
    func markProductAsUnsold(product: Product, completion: ProductCompletion?)
    
    
    // MARK: - (un)Favorite product
    
    func saveFavorite(product: Product, completion: ProductCompletion?)
    
    func deleteFavorite(product: Product, completion: ProductCompletion?)
    
    func updateFavoritesInfo(products: [Product]) -> [Product]
    
    
    // MARK: - User-Product relation
    
    func retrieveUserProductRelation(productId: String, completion: ProductUserRelationCompletion?)
    
    
    // MARK: - Product report

    func saveReport(product: Product, completion: ProductCompletion?)


    // MARK: - Products limbo

    func indexLimbo(completion: ProductsCompletion?)


    // MARK: - Products trending

    func indexTrending(params: IndexTrendingProductsParams, completion: ProductsCompletion?)


    // MARK: - Product Stats

    func retrieveStats(product: Product, completion: ProductStatsCompletion?)

    func incrementViews(product: Product, completion: ProductVoidCompletion?)

    func updateProductViewCounts()

}
