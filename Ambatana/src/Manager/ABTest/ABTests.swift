//
//  ABTests.swift
//  LetGo
//
//  Created by Dídac on 12/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxSwift

public struct ABTests {

    static let trackingData = Variable<[(String, AnyObject)]>([])

    static var directStickersOnProduct = BoolABDynamicVar(key: "directStickersOnProduct", defaultValue: false)
    static var postingDetailsMode = IntABDynamicVar(key: "postingDetailsMode", defaultValue: 0)
    static var appInviteFeedMode = IntABDynamicVar(key: "appInviteFeedMode", defaultValue: 0)
    static var showNPSSurvey = BoolABDynamicVar(key: "showNPSSurvey", defaultValue: false)
    static var profileVerifyOneButton = BoolABDynamicVar(key: "profileVerifyOneButton", defaultValue: false)
    static var nonStopProductDetail = BoolABDynamicVar(key: "nonStopProductDetail", defaultValue: false)
    static var onboardingPermissionsMode = IntABDynamicVar(key: "onboardingPermissionsMode", defaultValue: 0)
    static var incentivatePostingMode = IntABDynamicVar(key: "incentivatePostingMode", defaultValue: 0)
    static var messageOnFavorite = IntABDynamicVar(key: "messageOnFavorite", defaultValue: 0)

    static private var allVariables: [ABVariable] {
        return [directStickersOnProduct, postingDetailsMode, appInviteFeedMode, showNPSSurvey, profileVerifyOneButton,
                nonStopProductDetail, onboardingPermissionsMode, incentivatePostingMode, messageOnFavorite]
    }

    static func registerVariables() {
        allVariables.forEach { $0.register() }
    }

    static func variablesUpdated() {
        trackingData.value = allVariables.flatMap{ $0.trackingData }
    }
}
