//
//  FavoritesDAO.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 13/1/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

protocol FavoritesDAO {
    var favorites: [String] { get }
    func save(listings: [Listing])
    func save(listing: Listing)
    func save(listingIds: [String])
    func save(listingId: String)
    func remove(listingId: String)
    func remove(listing: Listing)
    func clean()
}

extension FavoritesDAO {
    func save(listings: [Listing]) {
        let ids = listings.flatMap{$0.objectId}
        save(listingIds: ids)
    }
    
    func save(listingId: String) {
        save(listingIds: [listingId])
    }
    
    func save(listing: Listing) {
        save(listings: [listing])
    }
    
    func remove(listing: Listing) {
        if let listingId = listing.objectId {
            remove(listingId: listingId)
        }
    }
}
