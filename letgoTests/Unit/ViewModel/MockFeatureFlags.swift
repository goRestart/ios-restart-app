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
    
    static var websocketChat: Bool = false
    static var notificationsSection: Bool = false
    static var userReviews: Bool = false
    static var showNPSSurvey: Bool = false
    static var messageOnFavoriteRound2: MessageOnFavoriteRound2Mode = .NoMessage
    static var interestedUsersMode: InterestedUsersMode = .NoNotification
    static var filtersReorder: Bool = false
    static var freePostingMode: FreePostingMode = .OneButton
    static var directPostInOnboarding: Bool = false
    static var shareButtonWithIcon: Bool = false
    static var productDetailShareMode: ProductDetailShareMode = .Native
    static var periscopeChat: Bool = false
    static var chatHeadBubbles: Bool = false
    static var showLiquidProductsToNewUser: Bool = false
    static var keywordsTravelCollection: Bool = false
}
