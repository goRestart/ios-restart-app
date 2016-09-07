//
//  FavoritesUDDAO.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 13/1/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation

final class FavoritesUDDAO: FavoritesDAO {
    static let FavoritesKey = "FavoritesUDKey"
    
    let userDefaults: NSUserDefaults
    private var favoritesSet: Set<String> = Set<String>()
    
    
    // MARK: - Lifecycle
    
    init(userDefaults: NSUserDefaults) {
        self.userDefaults = userDefaults
        self.favoritesSet = fetch()
    }
    
    
    // MARK: - FavoritesDAO
    
    /// Computed variable to access the favorited product IDs
    /// Internally the cache is saved in a Set, but this var will return an Array
    var favorites: [String] {
        return Array(favoritesSet)
    }
    
    
    // MARK: - Public methods
    
    /**
    Save the given products as Favorited. Will be saved in the DAO cache and in UserDefaults
    
    - parameter productIDs: Products IDs favorited
    */
    func save(productIDs: [String]) {
        favoritesSet = favoritesSet.union(Set(productIDs))
        sync()
    }
    
    /**
    Remove the given product from Favorites. Will be updated in the DAO cache and in UserDefaults
    
    - parameter productId: Product ID no longer favorited.
    */
    func remove(productId: String) {
        favoritesSet.remove(productId)
        sync()
    }
    
    func clean() {
        userDefaults.removeObjectForKey(FavoritesUDDAO.FavoritesKey)
        favoritesSet.removeAll()
    }
    
    
    // MARK: - Private methods
    
    /**
    Save the current DAO cache in UserDefaults
    */
    private func sync() {
        userDefaults.setValue(Array(favoritesSet), forKey: FavoritesUDDAO.FavoritesKey)
    }
    
    /**
    Return the favorites stored in UserDefaults
    
    - returns: Set of Product IDs
    */
    private func fetch() -> Set<String> {
        guard let array = userDefaults.arrayForKey(FavoritesUDDAO.FavoritesKey) else { return Set<String>() }
        return Set<String>(array.flatMap{$0 as? String})
    }
}