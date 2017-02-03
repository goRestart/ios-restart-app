//
//  ProductsLimboDAO.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 13/05/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

protocol ProductsLimboDAO: class {
    var productIds: [String] { get }
    func save(_ productId: String)
    func save(_ productIds: [String])
    func remove(_ productId: String)
    func removeAll()
}
