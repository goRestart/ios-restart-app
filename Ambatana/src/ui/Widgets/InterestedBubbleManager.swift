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

    func shouldShowInterestedBubbleForProduct(id: String) -> Bool {
        return interestedBubbleShownForProducts.count < Constants.maxInterestedBubblesPerSession &&
            !interestedBubbleAlreadyShownForProduct(id)
    }

    private func interestedBubbleAlreadyShownForProduct(id: String) -> Bool {
        return interestedBubbleShownForProducts.contains(id)
    }
}