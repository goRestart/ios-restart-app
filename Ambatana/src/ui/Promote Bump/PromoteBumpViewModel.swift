//
//  PromoteBumpViewModel.swift
//  LetGo
//
//  Created by Dídac on 16/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation


class PromoteBumpViewModel: BaseViewModel {

    var navigator: PromoteBumpNavigator?
    private var listingId: String
    private var bumpUpProductData: BumpUpProductData
    private var typePage: EventParameterTypePage?

    var titleText: String {
        return LGLocalizedString.promoteBumpTitle
    }

    var sellFasterImage: UIImage? {
        return UIImage(named: "bumpup2X")
    }
    var sellFasterText: String {
        return LGLocalizedString.promoteBumpSellFasterButton
    }

    var laterText: String {
        return LGLocalizedString.promoteBumpLaterButton
    }


    // MARK: - lifecycle

    init(listingId: String,
         bumpUpProductData: BumpUpProductData,
         typePage: EventParameterTypePage?) {
        self.listingId = listingId
        self.bumpUpProductData = bumpUpProductData
        self.typePage = typePage
    }


    // MARK: - public methods

    func sellFasterButtonPressed() {
        navigator?.openSellFaster(listingId: listingId,
                                  bumpUpProductData: bumpUpProductData,
                                  typePage: typePage)
    }

    func laterButtonPressed() {
        navigator?.promoteBumpDidCancel()
    }
}
