//
//  InterestedBubbleManager.swift
//  LetGo
//
//  Created by Dídac on 23/09/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

class InterestedBubbleManager {

    static let sharedInstance: InterestedBubbleManager = InterestedBubbleManager()


    // Interested bubble logic methods

    private var interestedBubbleShownForProducts: [String] = []

    func showInterestedBubbleForProduct(id: String) {
        interestedBubbleShownForProducts.append(id)
    }

    /**
     Conditions to show bubble:

     case .NoNotification:  NEVER

     case .Original:  On the FIRST product selected from the list, and when the user favorites a product

     case .LimitedPrints: On EVERY SHOWN PRODUCT (first or not) that has favorites with a max of 3 bubbles shown per
                            session and when the user favorites a product
     
     common conditions to NOT show the interested bubble:
        - the bubble has already been shown for this product (is saved in the "interestedBubbleShownForProducts" array)
     
     */

    func shouldShowInterestedBubbleForProduct(id: String, fromFavoriteAction: Bool, forFirstProduct isFirstProduct: Bool, featureFlags: FeatureFlags) -> Bool {

        var featureFlagDependantValue: Bool = true
        switch featureFlags.interestedUsersMode {
        case .NoNotification:
            return false
        case .Original:
            featureFlagDependantValue = (isFirstProduct || fromFavoriteAction) &&
                interestedBubbleShownForProducts.count < Constants.maxInterestedBubblesPerSessionOriginal
        case .LimitedPrints:
            featureFlagDependantValue = interestedBubbleShownForProducts.count < Constants.maxInterestedBubblesPerSessionLimitedPrints
        }

        return !interestedBubbleAlreadyShownForProduct(id) && featureFlagDependantValue
    }

    private func interestedBubbleAlreadyShownForProduct(id: String) -> Bool {
        return interestedBubbleShownForProducts.contains(id)
    }
}
