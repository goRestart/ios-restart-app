//
//  FavoritesDAO.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 13/1/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

protocol FavoritesDAO {
    var favorites: [String] { get }
    func save(_ products: [Product])
    func save(_ product: Product)
    func save(_ productIDs: [String])
    func save(_ productId: String)
    func remove(_ productId: String)
    func remove(_ product: Product)
    func clean()
}

extension FavoritesDAO {
    func save(_ products: [Product]) {
        let ids = products.flatMap{$0.objectId}
        save(ids)
    }
    
    func save(_ productId: String) {
        save([productId])
    }
    
    func save(_ product: Product) {
        save([product])
    }
    
    func remove(_ product: Product) {
        if let productId = product.objectId {
            remove(productId)
        }
    }
}
