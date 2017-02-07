//
//  ProductRepository.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 8/1/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result
import RxSwift

public typealias ProductStatsResult = Result<ProductStats, RepositoryError>
public typealias ProductStatsCompletion = (ProductStatsResult) -> Void

public typealias ProductUserRelationResult = Result<UserProductRelation, RepositoryError>
public typealias ProductUserRelationCompletion = (ProductUserRelationResult) -> Void

public typealias ProductResult = Result<Product, RepositoryError>
public typealias ProductCompletion = (ProductResult) -> Void

public typealias ProductVoidResult = Result<Void, RepositoryError>
public typealias ProductVoidCompletion = (ProductVoidResult) -> Void

public typealias ProductsResult = Result<[Product], RepositoryError>
public typealias ProductsCompletion = (ProductsResult) -> Void

public typealias ProductBuyersResult = Result<[UserProduct], RepositoryError>
public typealias ProductBuyersCompletion = (ProductBuyersResult) -> Void


public enum ProductEvent {
    case create(Product)
    case update(Product)
    case delete(String)
    case favorite(Product)
    case unFavorite(Product)
    case sold(String)
    case unSold(String)

    var product: Product? {
        switch self {
        case let .create(product):
            return product
        case let .update(product):
            return product
        case let .favorite(product):
            return product
        case let .unFavorite(product):
            return product
        case .delete, .sold, .unSold:
            return nil
        }
    }
}


public protocol ProductRepository {

    var events: Observable<ProductEvent> { get }
    func updateEventsFor(productId: String) -> Observable<Product>

    func buildNewProduct(_ name: String?, description: String?, price: ProductPrice, category: ProductCategory) -> Product?

    func updateProduct(_ product: Product, name: String?, description: String?, price: ProductPrice,
                              currency: Currency, location: LGLocationCoordinates2D?, postalAddress: PostalAddress?,
                              category: ProductCategory) -> Product

    
    // MARK: - Product CRUD
    
    func index(_ params: RetrieveProductsParams, completion: ProductsCompletion?)
    func index(userId: String, params: RetrieveProductsParams, completion: ProductsCompletion?)
    func indexRelated(productId: String, params: RetrieveProductsParams, completion: ProductsCompletion?)
    func indexDiscover(productId: String, params: RetrieveProductsParams, completion: ProductsCompletion?)
    func indexFavorites(_ userId: String, completion: ProductsCompletion?)
    func retrieve(_ productId: String, completion: ProductCompletion?)
    func create(_ product: Product, images: [UIImage], progress: ((Float) -> Void)?, completion: ProductCompletion?)
    func create(_ product: Product, images: [File], completion: ProductCompletion?)
    func update(_ product: Product, images: [UIImage], progress: ((Float) -> Void)?, completion: ProductCompletion?)
    func update(_ product: Product, oldImages: [File], newImages: [UIImage], progress: ((Float) -> Void)?, completion: ProductCompletion?)
    func update(_ product: Product, images: [File], completion: ProductCompletion?)
    func delete(_ product: Product, completion: ProductCompletion?)
    
    
    // MARK: - Mark product as (un)sold
    
    func markProductAsSold(_ productId: String, buyerId: String?, completion: ProductVoidCompletion?)
    func markProductAsSold(_ product: Product, buyerId: String?, completion: ProductCompletion?)
    func markProductAsUnsold(_ product: Product, completion: ProductCompletion?)
    
    
    // MARK: - (un)Favorite product
    
    func saveFavorite(_ product: Product, completion: ProductCompletion?)
    func deleteFavorite(_ product: Product, completion: ProductCompletion?)
    func updateFavoritesInfo(_ products: [Product]) -> [Product]
    
    
    // MARK: - User-Product relation
    
    func retrieveUserProductRelation(_ productId: String, completion: ProductUserRelationCompletion?)
    
    
    // MARK: - Product report

    func saveReport(_ product: Product, completion: ProductCompletion?)


    // MARK: - Products limbo

    func indexLimbo(_ completion: ProductsCompletion?)


    // MARK: - Products trending

    func indexTrending(_ params: IndexTrendingProductsParams, completion: ProductsCompletion?)


    // MARK: - Product Stats

    func retrieveStats(_ product: Product, completion: ProductStatsCompletion?)
    func incrementViews(_ product: Product, completion: ProductVoidCompletion?)
    func updateProductViewCounts()

    // MARK: - Possible buyers

    func possibleBuyersOf(product: Product, completion: ProductBuyersCompletion?)
}
