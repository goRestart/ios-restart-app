//
//  ProductsLimboDAO.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 13/05/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

protocol ProductsLimboDAO: class {
    var productIds: [String] { get }
    func save(_ product: Product)
    func save(_ products: [Product])
    func remove(_ product: Product)
    func removeAll()
}
