//
//  LGProductRepository.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 18/11/2016.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result
import RxSwift
import RxSwiftExt


final class LGProductRepository: ProductRepository {

    var events: Observable<ProductEvent> {
        return eventBus.asObservable()
    }

    private let eventBus = PublishSubject<ProductEvent>()

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
        guard let myUser = myUserRepository.myUser, let lgLocation = locationManager.currentLocation else { return nil }

        let currency: Currency
        let postalAddress = locationManager.currentLocation?.postalAddress ?? PostalAddress.emptyAddress()
        if let countryCode = postalAddress.countryCode {
            currency = currencyHelper.currencyWithCountryCode(countryCode)
        } else {
            currency = LGCoreKitConstants.defaultCurrency
        }
        let location = LGLocationCoordinates2D(location: lgLocation)
        let languageCode = Locale.current.identifier
        let status = ProductStatus.pending
        let myUserProduct = LGUserProduct(user: myUser)
        return LGProduct(objectId: nil, updatedAt: nil, createdAt: nil, name: name, nameAuto: nil, descr: description,
                         price: price, currency: currency, location: location, postalAddress: postalAddress,
                         languageCode: languageCode, category: category, status: status, thumbnail: nil,
                         thumbnailSize: nil, images: [], user: myUserProduct, featured: false)
    }

    func updateProduct(_ product: Product, name: String?, description: String?, price: ProductPrice,
                       currency: Currency, location: LGLocationCoordinates2D?, postalAddress: PostalAddress?,
                       category: ProductCategory) -> Product {
        var product = LGProduct(product: product)
        product = product.updating(name: name)
        product = product.updating(price: price)
        product = product.updating(descr: description)
        product = product.updating(currency: currency)
        product = product.updating(category: category)
        
        if let location = location {
            product = product.updating(location: location)
            let newPostalAddress = postalAddress ?? PostalAddress.emptyAddress()
            product = product.updating(postalAddress: newPostalAddress)
        }
        if product.languageCode == nil {
            product = product.updating(languageCode: Locale.current.identifier)
        }
        return product
    }


    // MARK: - Product CRUD

    func index(_ params: RetrieveProductsParams, completion: ProductsCompletion?)  {
        dataSource.index(params.letgoApiParams, completion: updateCompletion(completion))
    }

    func index(userId: String, params: RetrieveProductsParams, completion: ProductsCompletion?)  {
        dataSource.indexForUser(userId, parameters: params.userProductApiParams,
                                completion: updateCompletion(completion))
    }

    func indexRelated(productId: String, params: RetrieveProductsParams, completion: ProductsCompletion?)  {
        dataSource.indexRelatedProducts(productId, parameters: params.relatedProductsApiParams,
                                        completion: updateCompletion(completion))
    }

    func indexDiscover(productId: String, params: RetrieveProductsParams, completion: ProductsCompletion?)  {
        dataSource.indexDiscoverProducts(productId, parameters: params.relatedProductsApiParams,
                                         completion: updateCompletion(completion))
    }

    func indexFavorites(_ userId: String, completion: ProductsCompletion?) {

        dataSource.indexFavorites(userId) { [weak self] result in
            if let error = result.error {
                completion?(ProductsResult(error: RepositoryError(apiError: error)))
            } else if let value = result.value {
                if let myUserId = self?.myUserRepository.myUser?.objectId, myUserId == userId {
                    self?.favoritesDAO.save(products: value)
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

    func retrieve(_ productId: String, completion: ProductCompletion?) {
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

    func create(_ product: Product, images: [UIImage], progress: ((Float) -> Void)?, completion: ProductCompletion?) {

        fileRepository.upload(images, progress: progress) { [weak self] result in
            if let value = result.value {
                self?.create(product, images: value, completion: completion)
            } else if let error = result.error {
                completion?(ProductResult(error: error))
            }
        }
    }

    func create(_ product: Product, images: [File], completion: ProductCompletion?) {

        var product = LGProduct(product: product)
        product = product.updating(images: images)
        dataSource.create(product.encode()) { [weak self] result in

            if let product = result.value {
                // Cache the product in the limbo
                if let productId = product.objectId {
                    self?.productsLimboDAO.save(productId)
                }
                // Send event
                self?.eventBus.onNext(.create(product))
            }
            handleApiResult(result, completion: completion)
        }
    }

    func update(_ product: Product, images: [UIImage], progress: ((Float) -> Void)?, completion: ProductCompletion?) {
        update(product, oldImages: [], newImages: images, progress: progress, completion: completion)
    }

    func update(_ product: Product, oldImages: [File], newImages: [UIImage], progress: ((Float) -> Void)?,
                completion: ProductCompletion?) {
        fileRepository.upload(newImages, progress: progress) { [weak self] result in
            if let value = result.value {
                let allImages = oldImages + value
                self?.update(product, images: allImages, completion: completion)
            } else if let error = result.error {
                completion?(ProductResult(error: error))
            }
        }
    }

    func update(_ product: Product, images: [File], completion: ProductCompletion?) {

        guard let productId = product.objectId else {
            completion?(ProductResult(error: .internalError(message: "Missing objectId in Product")))
            return
        }

        var newProduct = LGProduct(product: product)
        newProduct = newProduct.updating(images: images)

        dataSource.update(productId, product: newProduct.encode()) { [weak self] result in
            if let product = result.value {
                // Send event
                self?.eventBus.onNext(.update(product))
            }
            handleApiResult(result, completion: completion)
        }
    }

    func delete(_ product: Product, completion: ProductVoidCompletion?) {

        guard let productId = product.objectId else {
            completion?(ProductVoidResult(error: .internalError(message: "Missing objectId in Product")))
            return
        }

        dataSource.delete(productId) { [weak self] result in
            if let error = result.error {
                completion?(ProductVoidResult(error: RepositoryError(apiError: error)))
            } else if let _ = result.value {
                self?.productsLimboDAO.remove(productId)
                self?.eventBus.onNext(.delete(productId))
                completion?(ProductVoidResult(value: ()))
            }
        }
    }


    // MARK: - Mark product as (un)sold

    func markProductAsSold(_ productId: String, buyerId: String?, completion: ProductVoidCompletion?) {
        dataSource.markAsSold(productId, buyerId: buyerId) { [weak self] result in
            if let error = result.error {
                completion?(ProductVoidResult(error: RepositoryError(apiError: error)))
            } else {
                self?.eventBus.onNext(.sold(productId))
                completion?(ProductVoidResult(value: ()))
            }
        }
    }

    func markProductAsSold(_ product: Product, buyerId: String?, completion: ProductCompletion?) {

        guard let productId = product.objectId else {
            completion?(ProductResult(error: .internalError(message: "Missing objectId in Product")))
            return
        }

        self.markProductAsSold(productId, buyerId: buyerId) { result in
            if let error = result.error {
                completion?(ProductResult(error: error))
            } else {
                let newProduct = LGProduct(product: product).updating(status: .sold)
                completion?(ProductResult(value: newProduct))
            }
        }
    }

    func markProductAsUnsold(_ product: Product, completion: ProductCompletion?) {

        guard let productId = product.objectId else {
            completion?(ProductResult(error: .internalError(message: "Missing objectId in Product")))
            return
        }

        dataSource.markAsUnSold(productId) { [weak self] result in
            if let error = result.error {
                completion?(ProductResult(error: RepositoryError(apiError: error)))
            } else if let _ = result.value {
                var newProduct = LGProduct(product: product)
                newProduct = newProduct.updating(status: .approved)
                self?.eventBus.onNext(.unSold(productId))
                completion?(ProductResult(value: newProduct))
            }
        }
    }


    // MARK: - (un)Favorite product

    func saveFavorite(_ product: Product, completion: ProductCompletion?) {
        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(ProductResult(error: .internalError(message: "Missing objectId in MyUser")))
            return
        }

        guard let productId = product.objectId else {
            completion?(ProductResult(error: .internalError(message: "Missing objectId in Product")))
            return
        }

        dataSource.saveFavorite(productId, userId: userId) { [weak self] result in
            if let error = result.error {
                completion?(ProductResult(error: RepositoryError(apiError: error)))
            } else if let _ = result.value {
                var newProduct = LGProduct(product: product)
                newProduct.favorite = true
                self?.favoritesDAO.save(product: product)
                self?.eventBus.onNext(.favorite(newProduct))
                completion?(ProductResult(value: newProduct))
            }
        }
    }

    func deleteFavorite(_ product: Product, completion: ProductCompletion?) {
        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(ProductResult(error: .internalError(message: "Missing objectId in MyUser")))
            return
        }

        guard let productId = product.objectId else {
            completion?(ProductResult(error: .internalError(message: "Missing objectId in Product")))
            return
        }

        dataSource.deleteFavorite(productId, userId: userId)  { [weak self] result in
            if let error = result.error {
                completion?(ProductResult(error: RepositoryError(apiError: error)))
            } else if let _ = result.value {
                var newProduct = LGProduct(product: product)
                newProduct.favorite = false
                self?.favoritesDAO.remove(product: product)
                self?.eventBus.onNext(.unFavorite(newProduct))
                completion?(ProductResult(value: newProduct))
            }
        }
    }

    func updateFavoritesInfo(_ products: [Product]) -> [Product] {
        let favorites = favoritesDAO.favorites
        return setFavorites(products, favorites: favorites)
    }


    // MARK: - User-Product relation

    func retrieveUserProductRelation(_ productId: String, completion: ProductUserRelationCompletion?) {
        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(ProductUserRelationResult(error: .internalError(message: "Missing objectId in MyUser")))
            return
        }

        dataSource.retrieveRelation(productId, userId: userId) { result in
            handleApiResult(result, success: { [weak self] value in
                value.isFavorited ? self?.favoritesDAO.save(productId: productId) : self?.favoritesDAO.remove(productId: productId)
                }, completion: completion)
        }
    }


    // MARK: - Product report

    func saveReport(_ product: Product, completion: ProductCompletion?) {
        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(ProductResult(error: .internalError(message: "Missing objectId in MyUser")))
            return
        }

        guard let productId = product.objectId else {
            completion?(ProductResult(error: .internalError(message: "Missing objectId in Product")))
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

    func indexLimbo(_ completion: ProductsCompletion?) {
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
                let productIds = products.flatMap { $0.objectId }
                self?.productsLimboDAO.save(productIds)

                completion?(ProductsResult(value: products))
            }
        }
    }


    // MARK: - Products trending

    func indexTrending(_ params: IndexTrendingProductsParams, completion: ProductsCompletion?) {
        dataSource.indexTrending(params.letgoApiParams, completion: updateCompletion(completion))
    }


    // MARK: - Product Stats

    func retrieveStats(_ product: Product, completion: ProductStatsCompletion?) {

        guard let productId = product.objectId else {
            completion?(ProductStatsResult(error: .internalError(message: "Missing objectId in Product")))
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

    func incrementViews(_ product: Product, completion: ProductVoidCompletion?) {

        guard let productId = product.objectId else {
            completion?(ProductVoidResult(error: .internalError(message: "Missing objectId in Product")))
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

    func updateProductViewCounts() {
        guard !viewedProductIds.isEmpty else { return }
        updateProductViewsBatch(Array(viewedProductIds), completion: nil)
        viewedProductIds = []
    }


    // MARK: - Possible buyers

    func possibleBuyersOf(productId: String, completion: ProductBuyersCompletion?) {
        guard let _ = myUserRepository.myUser?.objectId else {
            completion?(ProductBuyersResult(error: .internalError(message: "Not logged in")))
            return
        }
        dataSource.possibleBuyersOf(productId: productId) { result in
            handleApiResult(result, completion: completion)
        }
    }


    // MARK: - Private funcs

    private func setFavorites(_ products: [Product], favorites: [String]) -> [Product] {

        var newProducts: [Product] = []

        for product in products {
            guard let objectId = product.objectId else { continue }
            var newProduct = LGProduct(product: product)
            newProduct.favorite = favorites.contains(objectId)
            newProducts.append(newProduct)
        }

        return newProducts
    }

    private func updateCompletion(_ completion: ProductsCompletion?) -> ProductsDataSourceCompletion {
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

    private func updateProductViewsBatch(_ productIds: [String], completion: ProductVoidCompletion?) {
        dataSource.updateStats(productIds, action: "incr-views") { result in
            if let error = result.error {
                completion?(ProductVoidResult(error: RepositoryError(apiError: error)))
            } else if let _ = result.value {
                completion?(ProductVoidResult(value: ()))
            }
        }
    }
}

