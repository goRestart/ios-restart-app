//
//  ProductRepository.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 8/1/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation
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


public final class ProductRepository {
    let dataSource: ProductDataSource
    let myUserRepository: MyUserRepository
    let favoritesDAO: FavoritesDAO
    let productsLimboDAO: ProductsLimboDAO
    let fileRepository: FileRepository
    let locationManager: LocationManager
    let currencyHelper: CurrencyHelper
    var viewedProductIds: Set<String>

    

    // MARK: - Lifecycle
    
    init(productDataSource: ProductDataSource, myUserRepository: MyUserRepository, fileRepository: FileRepository,
         favoritesDAO: FavoritesDAO, productsLimboDAO: ProductsLimboDAO, locationManager: LocationManager,
         currencyHelper: CurrencyHelper) {
        self.dataSource = productDataSource
        self.myUserRepository = myUserRepository
        self.fileRepository = fileRepository
        self.favoritesDAO = favoritesDAO
        self.productsLimboDAO = productsLimboDAO
        self.locationManager = locationManager
        self.currencyHelper = currencyHelper
        self.viewedProductIds = []
    }

    public func buildNewProduct(name: String? = nil, description: String? = nil, price: Double? = nil,
                                category: ProductCategory = .Unassigned) -> Product? {
        guard let myUser = myUserRepository.myUser, lgLocation = locationManager.currentLocation else { return nil }

        let currency: Currency
        let postalAddress = locationManager.currentPostalAddress ?? PostalAddress.emptyAddress()
        if let countryCode = postalAddress.countryCode {
            currency = currencyHelper.currencyWithCountryCode(countryCode)
        } else {
            currency = LGCoreKitConstants.defaultCurrency
        }
        let location = LGLocationCoordinates2D(location: lgLocation)
        let languageCode = NSLocale.currentLocale().localeIdentifier
        let status = ProductStatus.Pending

        return LGProduct(objectId: nil, updatedAt: nil, createdAt: nil, name: name, nameAuto: nil, descr: description,
                         price: price, currency: currency, location: location, postalAddress: postalAddress,
                         languageCode: languageCode, category: category, status: status, thumbnail: nil,
                         thumbnailSize: nil, images: [], user: myUser)
    }
    
    public func build(fromChatproduct chatProduct: ChatProduct, chatInterlocutor: ChatInterlocutor) -> Product {
        return LGProduct(chatProduct: chatProduct, chatInterlocutor: chatInterlocutor)
    }

    public func updateProduct(product: Product, name: String?, description: String?, price: Double?,
                              currency: Currency, location: LGLocationCoordinates2D?, postalAddress: PostalAddress?,
                              category: ProductCategory) -> Product {
        var product = LGProduct(product: product)
        product.name = name
        product.price = price
        product.descr = description
        product.currency = currency

        if let location = location {
            product.location = location
            product.postalAddress = postalAddress ?? PostalAddress.emptyAddress()
        }

        product.category = category
        if product.languageCode == nil {
            product.languageCode = NSLocale.currentLocale().localeIdentifier
        }
        return product
    }

    
    // MARK: - Product CRUD
    
    public func index(params: RetrieveProductsParams, pageOffset: Int = 0, completion: ProductsCompletion?)  {
        var newParams: RetrieveProductsParams = params
        newParams.offset = pageOffset
        dataSource.index(newParams.letgoApiParams, completion: updateCompletion(completion))
    }

    public func index(userId userId: String, params: RetrieveProductsParams, pageOffset: Int = 0,
                             completion: ProductsCompletion?)  {
        var newParams: RetrieveProductsParams = params
        newParams.offset = pageOffset
        dataSource.indexForUser(userId, parameters: newParams.userProductApiParams,
                                completion: updateCompletion(completion))
    }

    public func indexRelated(productId productId: String, params: RetrieveProductsParams, pageOffset: Int = 0,
                             completion: ProductsCompletion?)  {
        var newParams: RetrieveProductsParams = params
        newParams.offset = pageOffset
        dataSource.indexRelatedProducts(productId, parameters: newParams.relatedProductsApiParams,
                                        completion: updateCompletion(completion))
    }

    public func indexDiscover(productId productId: String, params: RetrieveProductsParams, pageOffset: Int = 0,
                              completion: ProductsCompletion?)  {
        var newParams: RetrieveProductsParams = params
        newParams.offset = pageOffset
        dataSource.indexDiscoverProducts(productId, parameters: newParams.relatedProductsApiParams,
                                         completion: updateCompletion(completion))
    }
    
    public func indexFavorites(userId: String, completion: ProductsCompletion?) {
        
        dataSource.indexFavorites(userId) { [weak self] result in
            if let error = result.error {
                completion?(ProductsResult(error: RepositoryError(apiError: error)))
            } else if let value = result.value {
                if let myUserId = self?.myUserRepository.myUser?.objectId where myUserId == userId {
                    self?.favoritesDAO.save(value)
                }
                var products = value
                if let favorites = self?.favoritesDAO.favorites,
                    let favoritedProducts = self?.setFavorites(value, favorites: favorites) {
                        products = favoritedProducts
                }
                completion?(ProductsResult(value: products))
            }
        }
    }
    
    public func retrieve(productId: String, completion: ProductCompletion?) {
        let favorites = favoritesDAO.favorites
        dataSource.retrieve(productId) { result in
            if let error = result.error {
                completion?(ProductResult(error: RepositoryError(apiError: error)))
            } else if let value = result.value {
                var newProduct = LGProduct(product: value)
                if let objectId = newProduct.objectId {
                    newProduct.favorite = favorites.contains(objectId)
                }
                completion?(ProductResult(value: newProduct))
            }
        }
    }
    
    public func create(product: Product, images: [UIImage], progress: (Float -> Void)?, completion: ProductCompletion?) {
        
        fileRepository.upload(images, progress: progress) { [weak self] result in
            if let value = result.value {
                self?.create(product, images: value, completion: completion)
            } else if let error = result.error {
                completion?(ProductResult(error: error))
            }
        }
    }
    
    public func create(product: Product, images: [File], completion: ProductCompletion?) {

        var product = LGProduct(product: product)
        product.images = images
        dataSource.create(product.encode()) { [weak self] result in

            // Cache the product in the limbo
            if let product = result.value {
                self?.productsLimboDAO.save(product)
            }
            handleApiResult(result, completion: completion)
        }
    }
    
    public func update(product: Product, images: [UIImage], progress: (Float -> Void)?, completion: ProductCompletion?) {
        update(product, oldImages: [], newImages: images, progress: progress, completion: completion)
    }
    
    public func update(product: Product, oldImages: [File], newImages: [UIImage], progress: (Float -> Void)?, completion: ProductCompletion?) {
        fileRepository.upload(newImages, progress: progress) { [weak self] result in
            if let value = result.value {
                let allImages = oldImages + value
                self?.update(product, images: allImages, completion: completion)
            } else if let error = result.error {
                completion?(ProductResult(error: error))
            }
        }
    }
    
    public func update(product: Product, images: [File], completion: ProductCompletion?) {
        
        guard let productId = product.objectId else {
            completion?(ProductResult(error: .Internal(message: "Missing objectId in Product")))
            return
        }
        
        var newProduct = LGProduct(product: product)
        newProduct.images = images
        
        dataSource.update(productId, product: newProduct.encode()) { result in
            handleApiResult(result, completion: completion)
        }
    }
   
    public func delete(product: Product, completion: ProductCompletion?) {
        
        guard let productId = product.objectId else {
            completion?(ProductResult(error: .Internal(message: "Missing objectId in Product")))
            return
        }
        
        dataSource.delete(productId) { result in
            if let error = result.error {
                completion?(ProductResult(error: RepositoryError(apiError: error)))
            } else if let _ = result.value {
                completion?(ProductResult(value: product))
            }
        }
    }
    
    
    // MARK: - Mark product as (un)sold
    
    public func markProductAsSold(productId: String, completion: ProductVoidCompletion?) {
        dataSource.markAs(sold: true, productId: productId) { result in
            if let error = result.error {
                completion?(ProductVoidResult(error: RepositoryError(apiError: error)))
            } else if let _ = result.value {
                completion?(ProductVoidResult(value: ()))
            }
        }
    }

    public func markProductAsSold(product: Product, completion: ProductCompletion?) {
        
        guard let productId = product.objectId else {
            completion?(ProductResult(error: .Internal(message: "Missing objectId in Product")))
            return
        }
        
        dataSource.markAs(sold: true, productId: productId) { result in
            if let error = result.error {
                completion?(ProductResult(error: RepositoryError(apiError: error)))
            } else if let _ = result.value {
                var newProduct = LGProduct(product: product)
                newProduct.status = .Sold
                completion?(ProductResult(value: newProduct))
            }
        }
    }
    
    public func markProductAsUnsold(product: Product, completion: ProductCompletion?) {
        
        guard let productId = product.objectId else {
            completion?(ProductResult(error: .Internal(message: "Missing objectId in Product")))
            return
        }
        
        dataSource.markAs(sold: false, productId: productId) { result in
            if let error = result.error {
                completion?(ProductResult(error: RepositoryError(apiError: error)))
            } else if let _ = result.value {
                var newProduct = LGProduct(product: product)
                newProduct.status = .Approved
                completion?(ProductResult(value: newProduct))
            }
        }
    }
    
    
    // MARK: - (un)Favorite product
    
    public func saveFavorite(product: Product, completion: ProductCompletion?) {
        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(ProductResult(error: .Internal(message: "Missing objectId in MyUser")))
            return
        }
        
        guard let productId = product.objectId else {
            completion?(ProductResult(error: .Internal(message: "Missing objectId in Product")))
            return
        }
        
        dataSource.saveFavorite(productId, userId: userId) { [weak self] result in
            if let error = result.error {
                completion?(ProductResult(error: RepositoryError(apiError: error)))
            } else if let _ = result.value {
                var newProduct = LGProduct(product: product)
                newProduct.favorite = true
                self?.favoritesDAO.save(product)
                completion?(ProductResult(value: newProduct))
            }
        }
    }
    
    public func deleteFavorite(product: Product, completion: ProductCompletion?) {
        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(ProductResult(error: .Internal(message: "Missing objectId in MyUser")))
            return
        }
        
        guard let productId = product.objectId else {
            completion?(ProductResult(error: .Internal(message: "Missing objectId in Product")))
            return
        }
        
        dataSource.deleteFavorite(productId, userId: userId)  { [weak self] result in
            if let error = result.error {
                completion?(ProductResult(error: RepositoryError(apiError: error)))
            } else if let _ = result.value {
                var newProduct = LGProduct(product: product)
                newProduct.favorite = false
                self?.favoritesDAO.remove(product)
                completion?(ProductResult(value: newProduct))
            }
        }
    }
    
    public func updateFavoritesInfo(products: [Product]) -> [Product] {
        let favorites = favoritesDAO.favorites
        return setFavorites(products, favorites: favorites)
    }
    
    
    // MARK: - User-Product relation
    
    public func retrieveUserProductRelation(productId: String, completion: ProductUserRelationCompletion?) {
        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(ProductUserRelationResult(error: .Internal(message: "Missing objectId in MyUser")))
            return
        }
        
        dataSource.retrieveRelation(productId, userId: userId) { result in
            handleApiResult(result, success: { [weak self] value in
                value.isFavorited ? self?.favoritesDAO.save(productId) : self?.favoritesDAO.remove(productId)
                }, completion: completion)
        }
    }
    
    
    // MARK: - Product report

    public func saveReport(product: Product, completion: ProductCompletion?) {
        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(ProductResult(error: .Internal(message: "Missing objectId in MyUser")))
            return
        }
        
        guard let productId = product.objectId else {
            completion?(ProductResult(error: .Internal(message: "Missing objectId in Product")))
            return
        }
        
        dataSource.saveReport(productId, userId: userId) { result in
            if let error = result.error {
                completion?(ProductResult(error: RepositoryError(apiError: error)))
            } else if let _ = result.value {
                completion?(ProductResult(value: product))
            }
        }
    }


    // MARK: - Products limbo

    public func indexLimbo(completion: ProductsCompletion?) {
        guard let _ = myUserRepository.myUser?.objectId else {
            completion?(Result<[Product], RepositoryError>(value: []))
            return
        }

        let productIds = productsLimboDAO.productIds
        guard !productIds.isEmpty else {
            completion?(Result<[Product], RepositoryError>(value: []))
            return
        }

        dataSource.indexLimbo(productIds) { [weak self] result in
            if let error = result.error {
                completion?(ProductsResult(error: RepositoryError(apiError: error)))
            } else if let products = result.value {
                self?.productsLimboDAO.removeAll()
                self?.productsLimboDAO.save(products)
                
                completion?(ProductsResult(value: products))
            }
        }
    }


    // MARK: - Products trending

    public func indexTrending(params: IndexTrendingProductsParams, completion: ProductsCompletion?) {
        dataSource.indexTrending(params.letgoApiParams, completion: updateCompletion(completion))
    }


    // MARK: - Product Stats

    public func retrieveStats(product: Product, completion: ProductStatsCompletion?) {

        guard let productId = product.objectId else {
            completion?(ProductStatsResult(error: .Internal(message: "Missing objectId in Product")))
            return
        }
        dataSource.retrieveStats(productId) { result in
            if let error = result.error {
                completion?(ProductStatsResult(error: RepositoryError(apiError: error)))
            } else if let stats = result.value {
                completion?(ProductStatsResult(value: stats))
            }
        }
    }

    public func incrementViews(product: Product, completion: ProductVoidCompletion?) {

        guard let productId = product.objectId else {
            completion?(ProductVoidResult(error: .Internal(message: "Missing objectId in Product")))
            return
        }
        viewedProductIds.insert(productId)

        if viewedProductIds.count >= LGCoreKitConstants.viewedProductsThreshold  {
            updateProductViewsBatch(Array(viewedProductIds), completion: completion)
            viewedProductIds = []
        } else {
            completion?(ProductVoidResult(value: ()))
        }
    }

    public func updateProductViewCounts() {
        guard !viewedProductIds.isEmpty else { return }
        updateProductViewsBatch(Array(viewedProductIds), completion: nil)
        viewedProductIds = []
    }


    // MARK: - Private funcs
    
    private func setFavorites(products: [Product], favorites: [String]) -> [Product] {
        
        var newProducts: [Product] = []
        
        for product in products {
            guard let objectId = product.objectId else { continue }
            var newProduct = LGProduct(product: product)
            newProduct.favorite = favorites.contains(objectId)
            newProducts.append(newProduct)
        }
        
        return newProducts
    }

    private func updateCompletion(completion: ProductsCompletion?) -> ProductsDataSourceCompletion {
            let favorites = favoritesDAO.favorites
            let defaultCompletion: ProductsDataSourceCompletion = { [weak self] result in
                if let error = result.error {
                    completion?(ProductsResult(error: RepositoryError(apiError: error)))
                } else if let value = result.value {
                    let products = self?.setFavorites(value, favorites: favorites)
                    completion?(ProductsResult(value: products ?? []))
                }
            }
            return defaultCompletion
    }

    private func updateProductViewsBatch(productIds: [String], completion: ProductVoidCompletion?) {
        dataSource.updateStats(productIds, action: "incr-views") { result in
            if let error = result.error {
                completion?(ProductVoidResult(error: RepositoryError(apiError: error)))
            } else if let _ = result.value {
                completion?(ProductVoidResult(value: ()))
            }
        }
    }
}
