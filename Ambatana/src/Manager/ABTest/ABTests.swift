//
//  ABTests.swift
//  LetGo
//
//  Created by Dídac on 12/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxSwift

public struct ABTests {

    static let trackingData = Variable<[String]>([])

    static var showNPSSurvey = BoolABDynamicVar(key: "showNPSSurvey", defaultValue: false)
    static var interestedUsersMode = IntABDynamicVar(key: "interestedUsersMode", defaultValue: 0)
    static var productDetailShareMode = IntABDynamicVar(key: "productDetailShareMode", defaultValue: 0)
    static var notificationCenterEnabled = BoolABDynamicVar(key: "notificationCenterEnabled", defaultValue: true)
    static var shareButtonWithIcon = BoolABDynamicVar(key: "shareButtonWithIcon", defaultValue: false)
    static var expressChatBanner = BoolABDynamicVar(key: "expressChatBanner", defaultValue: false)
    static var postAfterDeleteMode = IntABDynamicVar(key: "postAfterDeleteMode", defaultValue: 0)
    static var keywordsTravelCollection = IntABDynamicVar(key: "keywordsTravelCollection", defaultValue: 0)
    static var commercializerAfterPosting = BoolABDynamicVar(key: "commercializerAfterPosting", defaultValue: false)
    static var relatedProductsOnMoreInfo = BoolABDynamicVar(key: "relatedProductsOnMoreInfo", defaultValue: false)
    static var shareAfterPosting = BoolABDynamicVar(key: "shareAfterPosting", defaultValue: false)
    static var postingMultiPictureEnabled = BoolABDynamicVar(key: "postingMultiPictureEnabled", defaultValue: false)
    static var periscopeImprovement = BoolABDynamicVar(key: "periscopeImprovement", defaultValue: false)
    static var newQuickAnswers = BoolABDynamicVar(key: "newQuickAnswers", defaultValue: false)
    static var favoriteWithBadgeOnProfile = BoolABDynamicVar(key: "favoriteWithBadgeOnProfile", defaultValue: false)
    static var favoriteWithBubbleToChat = BoolABDynamicVar(key: "favoriteWithBubbleToChat", defaultValue: false)

    static private var allVariables: [ABVariable] {
        return [showNPSSurvey,
                interestedUsersMode,
                productDetailShareMode,
                notificationCenterEnabled,
                shareButtonWithIcon,
                expressChatBanner,
                postAfterDeleteMode,
                keywordsTravelCollection,
                commercializerAfterPosting,
                relatedProductsOnMoreInfo,
                shareAfterPosting,
                postingMultiPictureEnabled,
                periscopeImprovement,
                newQuickAnswers,
                favoriteWithBadgeOnProfile,
                favoriteWithBubbleToChat]
    }

    static func registerVariables() {
        allVariables.forEach { $0.register() }
    }

    static func variablesUpdated() {
        trackingData.value = allVariables.flatMap{ $0.trackingData }
    }
}
