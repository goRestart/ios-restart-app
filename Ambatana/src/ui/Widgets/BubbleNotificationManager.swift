//
//  BubbleNotificationManager.swift
//  LetGo
//
//  Created by Dídac on 22/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

class BubbleNotificationManager {

    static let sharedInstance: BubbleNotificationManager = BubbleNotificationManager()

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
