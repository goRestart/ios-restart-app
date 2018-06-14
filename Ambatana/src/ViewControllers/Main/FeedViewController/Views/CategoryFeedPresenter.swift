//
//  CategoryFeedPresenter.swift
//  LetGo
//
//  Created by Haiyan Ma on 25/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit

protocol CategoriesHeaderCellPresentable {
    var categories: [CategoryHeaderElement] { get }
    var categoryHighlighted: CategoryHeaderElement { get }
    var isMostSearchedItemsEnabled: Bool { get }
}

final class CategoryPresenter: BaseViewModel {
    
    private let featureFlags: FeatureFlaggeable
    
    
    // MARK:- Lifecycle
    
    init(featureFlags: FeatureFlaggeable = FeatureFlags.sharedInstance) {
        self.featureFlags = featureFlags
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CategoryPresenter: FeedPresenter {
    
    static var feedClass: AnyClass {
        return CategoriesFeedHeaderCell.self
    }
    
    var height: CGFloat {
        return CategoriesFeedHeaderCell.viewHeight
    }
}

extension CategoryPresenter: CategoriesHeaderCellPresentable {
    
    var categories: [CategoryHeaderElement] {
        var categoryHeaderElements: [CategoryHeaderElement] = []
        categoryHeaderElements.append(contentsOf: ListingCategory.visibleValuesInFeed(servicesIncluded: true,
                                                                                      realEstateIncluded: featureFlags.realEstateEnabled.isActive,
                                                                                      servicesHighlighted: false)
            .map { CategoryHeaderElement.listingCategory($0) })
        return categoryHeaderElements
    }
    
    var categoryHighlighted: CategoryHeaderElement {
        if featureFlags.realEstateEnabled.isActive {
            return CategoryHeaderElement.listingCategory(.realEstate)
        } else {
            return CategoryHeaderElement.listingCategory(.cars)
        }
    }
    
    var isMostSearchedItemsEnabled: Bool {
        return featureFlags.mostSearchedDemandedItems.isActive
    }
}
