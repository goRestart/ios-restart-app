//
//  LGUIKitConstants.swift
//  LetGo
//
//  Created by Dídac on 23/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

struct LGUIKitConstants {

    // MARK: - Constraint Constants
    // Distance To main view
    static let itemDistanceToTop = 15
    static let itemDistanceToBottom = 15
    static let itemDistanceToLeft = 15
    static let itemDistanceToRight = 15

    // Distance Between elements
    static let verticalDistanceLarge = 30
    static let verticalDistanceMedium = 20
    static let verticalDistanceSmall = 10

    static let horitzontalDistanceMedium = 10
    static let horitzontalDistanceSmall = 5
    
    static let tabBarSellFloatingButtonDistance: CGFloat = 15

    // Message Distances
    private static let messageLongDistance = 50
    private static let messageShortDistance = 10

    static let myMessageLeading = messageLongDistance
    static let myMessageTrailing = messageShortDistance
    static let otherMessageLeading = messageShortDistance
    static let otherMessageTrailing = messageLongDistance
    static let verticalDistanceMessages = 5

    // Max Widths
    static let alertWidth = 270
    static let tooltipWidth: CGFloat = 270

    // MARK: - Corner radius
    static let smallCornerRadius: CGFloat = 4
    static let mediumCornerRadius: CGFloat = 10
    static let bigCornerRadius: CGFloat = 15
    
    // MARK: - Button Heights
    static let bigButtonHeight: CGFloat = 50
    static let mediumButtonHeight: CGFloat = 44
    static let smallButtonHeight: CGFloat = 30
    static let tabBarSellFloatingButtonHeight: CGFloat = 60

    // MARK: - Sizes
    static var onePixelSize: CGFloat {
        return 1 / UIScreen.main.scale
    }
    static let enabledButtonHeight: CGFloat = 44

    //0.9 so it will consider images that are slightly vertical as horizontal ones (for better rendering)
    static let horizontalImageMinAspectRatio: CGFloat = 0.9

    // MARK: - Highlighted
    static let highlightedStateAlpha: CGFloat = 0.6

    // MARK: - Animation

    static let defaultAnimationTime: TimeInterval = 0.2

    // MARK: - Ads
    static let advertisementCellPlaceholderHeight: CGFloat = 220
    static let advertisementCellMoPubHeight: CGFloat = 290

    // MARK: - Map Pin
    static let mapPinHeight: CGFloat = 37
    static let mapPinWidth: CGFloat = 26
}
