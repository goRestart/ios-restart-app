//
//  ProductsLimboUDDAO.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 13/05/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

class ProductsLimboUDDAO {
    static let ProductsLimboMainKey = "ProductsLimbo"

    fileprivate let userDefaults: UserDefaults
    fileprivate var productsIdsSet: Set<String>


    convenience init() {
        let userDefaults = UserDefaults.standard
        self.init(userDefaults: userDefaults)
    }

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
        self.productsIdsSet = ProductsLimboUDDAO.fetch(userDefaults)
    }
}


// MARK : - ProductsLimboDAO

extension ProductsLimboUDDAO: ProductsLimboDAO {
    var productIds: [String] {
        return Array(productsIdsSet)
    }

    func save(_ product: Product) {
        guard let productId = product.objectId else { return }

        productsIdsSet.insert(productId)
        sync()
    }

    func save(_ products: [Product]) {
        let productIds = products.flatMap { $0.objectId }

        productsIdsSet = productsIdsSet.union(Set(productIds))
        sync()
    }

    func remove(_ product: Product) {
        guard let productId = product.objectId else { return }

        productsIdsSet.remove(productId)
        sync()
    }

    func removeAll() {
        productsIdsSet.removeAll()
        userDefaults.removeObject(forKey: ProductsLimboUDDAO.ProductsLimboMainKey)
    }
}

// MARK: - Private methods

private extension ProductsLimboUDDAO {
    func sync() {
        userDefaults.setValue(productIds, forKey: ProductsLimboUDDAO.ProductsLimboMainKey)
    }

    static func fetch(_ userDefaults: UserDefaults) -> Set<String> {
        guard let array = userDefaults.array(forKey: ProductsLimboUDDAO.ProductsLimboMainKey) else { return Set<String>() }
        return Set<String>(array.flatMap{$0 as? String})
    }
}
