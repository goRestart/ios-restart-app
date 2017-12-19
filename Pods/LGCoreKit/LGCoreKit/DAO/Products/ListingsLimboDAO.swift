//
//  ListingsLimboDAO.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 13/05/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

protocol ListingsLimboDAO: class {
    var listingIds: [String] { get }
    func save(_ listingId: String)
    func save(_ listingIds: [String])
    func remove(_ listingId: String)
    func removeAll()
}
