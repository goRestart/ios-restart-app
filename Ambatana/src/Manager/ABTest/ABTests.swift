//
//  ABTests.swift
//  LetGo
//
//  Created by Dídac on 12/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxSwift

struct ABTests {

    static let trackingData = Variable<[String]?>(nil)

    // Not used in code, Just a helper for marketing team
    static var marketingPush = IntABDynamicVar(key: "marketingPush", defaultValue: 0)

    static var showNPSSurvey = BoolABDynamicVar(key: "showNPSSurvey", defaultValue: false)
    static var notificationCenterEnabled = BoolABDynamicVar(key: "notificationCenterEnabled", defaultValue: true)
    static var postAfterDeleteMode = IntABDynamicVar(key: "postAfterDeleteMode", defaultValue: 0)
    static var keywordsTravelCollection = IntABDynamicVar(key: "keywordsTravelCollection", defaultValue: 0)
    static var relatedProductsOnMoreInfo = BoolABDynamicVar(key: "relatedProductsOnMoreInfo", defaultValue: false)
    static var shareAfterPosting = BoolABDynamicVar(key: "shareAfterPosting", defaultValue: false)
    static var postingMultiPictureEnabled = BoolABDynamicVar(key: "postingMultiPictureEnabled", defaultValue: false)
    static var userReviews = BoolABDynamicVar(key: "userReviews", defaultValue: false)
    static var newQuickAnswers = BoolABDynamicVar(key: "newQuickAnswers", defaultValue: false)
    static var favoriteWithBadgeOnProfile = BoolABDynamicVar(key: "favoriteWithBadgeOnProfile", defaultValue: false)
    static var favoriteWithBubbleToChat = BoolABDynamicVar(key: "favoriteWithBubbleToChat", defaultValue: false)
    static var captchaTransparent = BoolABDynamicVar(key: "captchaTransparent", defaultValue: false)
    static var passiveBuyersShowKeyboard = BoolABDynamicVar(key: "passiveBuyersShowKeyboard", defaultValue: false)
    static var filterIconWithLetters = BoolABDynamicVar(key: "filterIconWithLetters", defaultValue: false)
    static var editDeleteItemUxImprovement = BoolABDynamicVar(key: "editDeleteItemUxImprovement", defaultValue: false)
    static var bumpUpFreeTimeLimit = FloatABDynamicVar(key: "bumpUpFreeTimeLimit", defaultValue: 8)



    static private var allVariables: [ABVariable] {
        var result = [ABVariable]()

        result.append(marketingPush)
        result.append(showNPSSurvey)
        result.append(notificationCenterEnabled)
        result.append(postAfterDeleteMode)
        result.append(keywordsTravelCollection)
        result.append(relatedProductsOnMoreInfo)
        result.append(shareAfterPosting)
        result.append(postingMultiPictureEnabled)
        result.append(userReviews)
        result.append(newQuickAnswers)
        result.append(favoriteWithBadgeOnProfile)
        result.append(favoriteWithBubbleToChat)
        result.append(passiveBuyersShowKeyboard)
        result.append(captchaTransparent)
        result.append(filterIconWithLetters)
        result.append(editDeleteItemUxImprovement)
        result.append(bumpUpFreeTimeLimit)

        return result
    }

    static func registerVariables() {
        allVariables.forEach { $0.register() }
    }

    static func variablesUpdated() {
        trackingData.value = allVariables.flatMap { $0.trackingData }
    }
}
