//
//  FavoritesDAO.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 13/1/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

protocol FavoritesDAO {
    var favorites: [String] { get }
    func save(products: [Product])
    func save(product: Product)
    func save(productIDs: [String])
    func save(productId: String)
    func remove(productId: String)
    func remove(product: Product)
    func clean()
}

extension FavoritesDAO {
    func save(products: [Product]) {
        let ids = products.flatMap{$0.objectId}
        save(ids)
    }
    
    func save(productId: String) {
        save([productId])
    }
    
    func save(product: Product) {
        save([product])
    }
    
    func remove(product: Product) {
        if let productId = product.objectId {
            remove(productId)
        }
    }
}