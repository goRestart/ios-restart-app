//
//  ProductsLimboDAO.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 13/05/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

protocol ProductsLimboDAO: class {
    var productIds: [String] { get }
    func save(product: Product)
    func save(products: [Product])
    func remove(product: Product)
    func removeAll()
}
