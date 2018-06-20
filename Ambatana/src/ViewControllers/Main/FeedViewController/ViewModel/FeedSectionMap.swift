//
//  FeedSectionItem.swift
//  LetGo
//
//  Created by Stephen Walsh on 30/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation


// FIXME: Move this to CoreKit
enum FeedSectionMapType {
    case filters
    case pushPermissions
    case categories
    case listings
}

struct FeedSectionMap {
    
    let header: FeedPresenter?
    let items: [FeedPresenter]
    let footer: FeedPresenter?

    let type: FeedSectionMapType
    
    init(header: FeedPresenter? = nil,
         items: [FeedPresenter],
         footer: FeedPresenter? = nil,
         type: FeedSectionMapType) {
        self.header = header
        self.items = items
        self.footer = footer
        self.type = type
    }
}


// FIXME: Remove Dummy Instantiators

extension FeedSectionMap {
    
    static func makeFilterSection(filters: ListingFilters) -> FeedSectionMap {
        return FeedSectionMap(header: FilterTagFeedPresenter(filters: filters),
                              items: [],
                              type: FeedSectionMapType.filters)
    }
    
    static func makePushSection(delegate: PushPermissionsPresenterDelegate,
                                pushPermissionTracker: PushPermissionsTracker) -> FeedSectionMap {
        return FeedSectionMap(header: PushPermissionsPresenter(delegate: delegate,
                                                               pushPermissionTracker: pushPermissionTracker),
                              items: [],
                              type: FeedSectionMapType.pushPermissions)
    }
    
    static func makeCategorySection() -> FeedSectionMap {
        return FeedSectionMap(header: CategoryPresenter(),
                              items: [],
                              type: FeedSectionMapType.categories)
    }
    
    static func makeListingSection() -> FeedSectionMap {
        return FeedSectionMap(items: Array(repeatElement(EmptyFeedCellPresenter(),
                                                         count: 50)),
                              type: FeedSectionMapType.listings)
    }
}
