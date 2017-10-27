//
//  FeaturedInfoViewModel.swift
//  LetGo
//
//  Created by Dídac on 25/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

class FeaturedInfoViewModel: BaseViewModel {

    var titleText: String
    var sellFasterText: String
    var increaseVisibilityText: String
    var moreBuyersText: String

    weak var navigator: ListingDetailNavigator?


    // MARK: - Lifecycle

    override init() {
        self.titleText = LGLocalizedString.featuredInfoViewTitle
        self.sellFasterText = LGLocalizedString.featuredInfoViewSellFaster
        self.increaseVisibilityText = LGLocalizedString.featuredInfoViewIncreaseVisibility
        self.moreBuyersText = LGLocalizedString.featuredInfoViewMoreBuyers
    }


    // MARK: - Public methods

    func closeButtonPressed() {
        navigator?.closeFeaturedInfo()
    }
}
