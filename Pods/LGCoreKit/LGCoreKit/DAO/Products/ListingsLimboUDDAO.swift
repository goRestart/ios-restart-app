//
//  ListingsLimboUDDAO.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 13/05/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

class ListingsLimboUDDAO {
    static let ListingsLimboMainKey = "ProductsLimbo"

    fileprivate let userDefaults: UserDefaults
    fileprivate var listingsIdsSet: Set<String>


    convenience init() {
        let userDefaults = UserDefaults.standard
        self.init(userDefaults: userDefaults)
    }

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
        self.listingsIdsSet = ListingsLimboUDDAO.fetch(userDefaults)
    }
}


// MARK : - ListingsLimboDAO

extension ListingsLimboUDDAO: ListingsLimboDAO {
    var listingIds: [String] {
        return Array(listingsIdsSet)
    }

    func save(_ listingId: String) {
        listingsIdsSet.insert(listingId)
        sync()
    }

    func save(_ listingIds: [String]) {
        listingsIdsSet = listingsIdsSet.union(Set(listingIds))
        sync()
    }

    func remove(_ listingId: String) {
        listingsIdsSet.remove(listingId)
        sync()
    }

    func removeAll() {
        listingsIdsSet.removeAll()
        userDefaults.removeObject(forKey: ListingsLimboUDDAO.ListingsLimboMainKey)
    }
}

// MARK: - Private methods

private extension ListingsLimboUDDAO {
    func sync() {
        userDefaults.setValue(listingIds, forKey: ListingsLimboUDDAO.ListingsLimboMainKey)
    }

    static func fetch(_ userDefaults: UserDefaults) -> Set<String> {
        guard let array = userDefaults.array(forKey: ListingsLimboUDDAO.ListingsLimboMainKey) else { return Set<String>() }
        return Set<String>(array.flatMap{$0 as? String})
    }
}
