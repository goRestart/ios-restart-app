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
    func save(productIDs: [String])
    func save(productId: String)
    func remove(productId: String)
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
}