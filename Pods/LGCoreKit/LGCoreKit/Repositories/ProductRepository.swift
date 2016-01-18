//
//  ProductRepository.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 8/1/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation
import Result


public typealias ProductUserRelationResult = Result<UserProductRelation, RepositoryError>
public typealias ProductUserRelationCompletion = ProductUserRelationResult -> Void

public typealias ProductResult = Result<Product, RepositoryError>
public typealias ProductCompletion = ProductResult -> Void

public typealias ProductsResult = Result<[Product], RepositoryError>
public typealias ProductsCompletion = ProductsResult -> Void


public final class ProductRepository {
    
    public static let sharedInstance = ProductRepository()
    let dataSource: ProductDataSource
    let myUserRepository: MyUserRepository
    let favoritesDAO: FavoritesDAO
    let fileRepository: FileRepository
    
    public convenience init() {
        let dataSource = ProductApiDataSource()
        let myUserRepository = MyUserRepository.sharedInstance
        let fileRepository = LGFileRepository.sharedInstance
        let favoritesDAO = FavoritesUDDAO.sharedInstance
        self.init(productDataSource: dataSource, myUserRepository: myUserRepository, fileRepository: fileRepository,
            favoritesDAO: favoritesDAO)
    }
    
    init(productDataSource: ProductDataSource, myUserRepository: MyUserRepository, fileRepository: FileRepository,
        favoritesDAO: FavoritesDAO) {
            self.dataSource = productDataSource
            self.myUserRepository = myUserRepository
            self.fileRepository = fileRepository
            self.favoritesDAO = favoritesDAO
    }
    
    public func newProduct() -> Product? {
        var product = LGProduct()
        guard let myUser = myUserRepository.myUser, location = myUser.coordinates else { return nil }
        product.user = myUser
        product.location = location
        product.postalAddress = myUserRepository.myUser?.postalAddress ?? PostalAddress.emptyAddress()
        return product
    }

    public func updateProduct(product: Product, name: String?, price: Double?, description: String?,
        category: ProductCategory, currency: Currency?) -> Product {
            var product = LGProduct(product: product)
            product.name = name
            product.price = price
            product.descr = description
            product.category = category
            product.currency = currency
            return product
    }
    
    
    // MARK: - Product CRUD
    
    public func index(params: RetrieveProductsParams, pageOffset: Int = 0, completion: ProductsCompletion?)  {
        
        var newParams: RetrieveProductsParams = params
        newParams.offset = pageOffset
        let favorites = favoritesDAO.favorites
        
        let defaultCompletion: ProductsDataSourceCompletion = { [weak self] result in
            if let error = result.error {
                completion?(ProductsResult(error: RepositoryError(apiError: error)))
            } else if let value = result.value {
                let products = self?.setFavorites(value, favorites: favorites)
                completion?(ProductsResult(value: products ?? []))
            }
        }
        
        if let userId = params.userObjectId {
            dataSource.indexForUser(userId, parameters: newParams.userProductApiParams, completion: defaultCompletion)
        } else {
            dataSource.index(newParams.letgoApiParams, completion: defaultCompletion)
        }
    }
    
    public func indexFavorites(completion: ProductsCompletion?) {
        
        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(ProductsResult(error: .Internal(message: "Missing objectId in MyUser")))
            return
        }
        
        dataSource.indexFavorites(userId) { [weak self] result in
            if let error = result.error {
                completion?(ProductsResult(error: RepositoryError(apiError: error)))
            } else if let value = result.value {
                self?.favoritesDAO.save(value)
                let newProducts: [Product] = value.map {
                    var newProduct = LGProduct(product: $0)
                    newProduct.favorite = true
                    return newProduct
                }
                completion?(ProductsResult(value: newProducts))
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
        dataSource.create(product.encode()) { result in
            handleApiResult(result, completion: completion)
        }
    }
    
    public func update(product: Product, images: [UIImage], progress: (Float -> Void)?, completion: ProductCompletion?) {
        fileRepository.upload(images, progress: progress) { [weak self] result in
            if let value = result.value {
                self?.update(product, images: value, completion: completion)
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
        
        dataSource.update(productId, product: product.encode()) { result in
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
}