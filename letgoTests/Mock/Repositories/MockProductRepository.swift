//
//  MockProductRepository.swift
//  LetGo
//
//  Created by Eli Kohen on 07/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import RxSwift
import Result

class MockProductRepository: ProductRepository {

    var eventsBus = PublishSubject<ProductEvent>()
    var productsResult: ProductsResult?
    var productResult: ProductResult?
    var voidResult: ProductVoidResult?
    var userRelationResult: ProductUserRelationResult?
    var statsResult: ProductStatsResult?
    var buyersResult: ProductBuyersResult?

    var markAsSoldProductId: String?
    var markAsSoldBuyerId: String?

    var events: Observable<ProductEvent> {
        return eventsBus.asObservable()
    }
    func updateEventsFor(productId: String) -> Observable<Product> {
        let optionalProducts: Observable<Product?> = events.map {
            switch $0 {
            case .create, .delete, .favorite, .unFavorite, .sold, .unSold:
                return nil
            case let .update(product):
                if product.objectId == productId {
                    return product
                } else {
                    return nil
                }
            }
        }
        return optionalProducts.unwrap()
    }

    func buildNewProduct(_ name: String?, description: String?, price: ProductPrice, category: ProductCategory) -> Product? {
        let product = MockProduct()
        product.name = name
        product.descr = description
        product.price = price
        product.category = category
        return product
    }

    func updateProduct(_ product: Product, name: String?, description: String?, price: ProductPrice,
                       currency: Currency, location: LGLocationCoordinates2D?, postalAddress: PostalAddress?,
                       category: ProductCategory) -> Product {
        let result = MockProduct()
        result.objectId = product.objectId
        result.name = name
        result.descr = description
        result.price = price
        result.category = category
        result.currency = currency
        if let location = location {
            result.location = location
        }
        if let postalAddress = postalAddress {
            result.postalAddress = postalAddress
        }
        return result
    }


    // MARK: - Product CRUD

    func index(_ params: RetrieveProductsParams, completion: ProductsCompletion?) {
        performAfterDelayWithCompletion(completion, result: productsResult)
    }
    func index(userId: String, params: RetrieveProductsParams, completion: ProductsCompletion?) {
        performAfterDelayWithCompletion(completion, result: productsResult)
    }
    func indexRelated(productId: String, params: RetrieveProductsParams, completion: ProductsCompletion?) {
        performAfterDelayWithCompletion(completion, result: productsResult)
    }
    func indexDiscover(productId: String, params: RetrieveProductsParams, completion: ProductsCompletion?) {
        performAfterDelayWithCompletion(completion, result: productsResult)
    }
    func indexFavorites(_ userId: String, completion: ProductsCompletion?) {
        performAfterDelayWithCompletion(completion, result: productsResult)
    }
    func retrieve(_ productId: String, completion: ProductCompletion?) {
        performAfterDelayWithCompletion(completion, result: productResult)
    }
    func create(_ product: Product, images: [UIImage], progress: ((Float) -> Void)?, completion: ProductCompletion?) {
        performAfterDelayWithCompletion(completion, result: productResult)
    }
    func create(_ product: Product, images: [File], completion: ProductCompletion?) {
        performAfterDelayWithCompletion(completion, result: productResult)
    }
    func update(_ product: Product, images: [UIImage], progress: ((Float) -> Void)?, completion: ProductCompletion?) {
        performAfterDelayWithCompletion(completion, result: productResult)
    }
    func update(_ product: Product, oldImages: [File], newImages: [UIImage], progress: ((Float) -> Void)?, completion: ProductCompletion?) {
        performAfterDelayWithCompletion(completion, result: productResult)
    }
    func update(_ product: Product, images: [File], completion: ProductCompletion?) {
        performAfterDelayWithCompletion(completion, result: productResult)
    }
    func delete(_ product: Product, completion: ProductCompletion?) {
        performAfterDelayWithCompletion(completion, result: productResult)
    }


    // MARK: - Mark product as (un)sold

    func markProductAsSold(_ productId: String, buyerId: String?, completion: ProductVoidCompletion?) {
        markAsSoldProductId = productId
        markAsSoldBuyerId = buyerId
        performAfterDelayWithCompletion(completion, result: voidResult)
    }
    func markProductAsSold(_ product: Product, buyerId: String?, completion: ProductCompletion?) {
        markAsSoldProductId = product.objectId
        markAsSoldBuyerId = buyerId
        performAfterDelayWithCompletion(completion, result: productResult)
    }
    func markProductAsUnsold(_ product: Product, completion: ProductCompletion?) {
        performAfterDelayWithCompletion(completion, result: productResult)
    }


    // MARK: - (un)Favorite product

    func saveFavorite(_ product: Product, completion: ProductCompletion?) {
        performAfterDelayWithCompletion(completion, result: productResult)
    }
    func deleteFavorite(_ product: Product, completion: ProductCompletion?) {
        performAfterDelayWithCompletion(completion, result: productResult)
    }
    func updateFavoritesInfo(_ products: [Product]) -> [Product] {
        if let result = productsResult?.value {
            return result
        }
        return []
    }


    // MARK: - User-Product relation

    func retrieveUserProductRelation(_ productId: String, completion: ProductUserRelationCompletion?) {
        performAfterDelayWithCompletion(completion, result: userRelationResult)
    }


    // MARK: - Product report

    func saveReport(_ product: Product, completion: ProductCompletion?) {
        performAfterDelayWithCompletion(completion, result: productResult)
    }


    // MARK: - Products limbo

    func indexLimbo(_ completion: ProductsCompletion?) {
        performAfterDelayWithCompletion(completion, result: productsResult)
    }


    // MARK: - Products trending

    func indexTrending(_ params: IndexTrendingProductsParams, completion: ProductsCompletion?) {
        performAfterDelayWithCompletion(completion, result: productsResult)
    }


    // MARK: - Product Stats

    func retrieveStats(_ product: Product, completion: ProductStatsCompletion?) {
        performAfterDelayWithCompletion(completion, result: statsResult)
    }
    func incrementViews(_ product: Product, completion: ProductVoidCompletion?) {
        performAfterDelayWithCompletion(completion, result: voidResult)
    }
    func updateProductViewCounts() {

    }

    // MARK: - Possible buyers

    func possibleBuyersOf(product: Product, completion: ProductBuyersCompletion?) {
        performAfterDelayWithCompletion(completion, result: buyersResult)
    }
}
