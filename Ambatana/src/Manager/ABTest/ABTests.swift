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
    static var messageOnFavoriteRound2 = IntABDynamicVar(key: "messageOnFavoriteRound2", defaultValue: 0)
    static var interestedUsersMode = IntABDynamicVar(key: "interestedUsersMode", defaultValue: 0)
    static var filtersReorder = BoolABDynamicVar(key: "filtersReorder", defaultValue: false)
    static var directPostInOnboarding = BoolABDynamicVar(key: "directPostInOnboarding", defaultValue: false)
    static var productDetailShareMode = IntABDynamicVar(key: "productDetailShareMode", defaultValue: 0)
    static var notificationCenterEnabled = BoolABDynamicVar(key: "notificationCenterEnabled", defaultValue: true)
    static var persicopeChat = BoolABDynamicVar(key: "persicopeChat", defaultValue: false)
    static var shareButtonWithIcon = BoolABDynamicVar(key: "shareButtonWithIcon", defaultValue: false)
    static var chatHeadBubbles = BoolABDynamicVar(key: "chatHeadBubbles", defaultValue: false)
    static var expressChatBanner = BoolABDynamicVar(key: "expressChatBanner", defaultValue: false)
    static var showLiquidProductsToNewUser = BoolABDynamicVar(key: "showLiquidProductsToNewUser", defaultValue: false)
    static var keywordsTravelCollection = IntABDynamicVar(key: "keywordsTravelCollection", defaultValue: 0)
    static var commercializerAfterPosting = BoolABDynamicVar(key: "commercializerAfterPosting", defaultValue: false)
    
    static private var allVariables: [ABVariable] {
        return [showNPSSurvey, messageOnFavoriteRound2, interestedUsersMode, filtersReorder,
                directPostInOnboarding, productDetailShareMode, notificationCenterEnabled,
                persicopeChat, shareButtonWithIcon, chatHeadBubbles, expressChatBanner, showLiquidProductsToNewUser,
                keywordsTravelCollection, commercializerAfterPosting]
    }

    static func registerVariables() {
        allVariables.forEach { $0.register() }
    }

    static func variablesUpdated() {
        trackingData.value = allVariables.flatMap{ $0.trackingData }
    }
}
