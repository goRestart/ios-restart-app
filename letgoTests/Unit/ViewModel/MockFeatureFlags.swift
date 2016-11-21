//
//  MockFeatureFlags.swift
//  LetGo
//
//  Created by Juan Iglesias on 18/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

@testable import LetGo
import Foundation

class MockFeatureFlags: FeatureFlaggeable {
    
    var websocketChat: Bool = false
    var notificationsSection: Bool = false
    var userReviews: Bool = false
    var messageOnFavoriteRound2: MessageOnFavoriteRound2Mode = .NoMessage
    var interestedUsersMode: InterestedUsersMode = .NoNotification
    var filtersReorder: Bool = false
    var freePostingMode: FreePostingMode = .OneButton
    var directPostInOnboarding: Bool = false
    var shareButtonWithIcon: Bool = false
    var productDetailShareMode: ProductDetailShareMode = .Native
    var periscopeChat: Bool = false
    var chatHeadBubbles: Bool = false
    var showLiquidProductsToNewUser: Bool = false
}
