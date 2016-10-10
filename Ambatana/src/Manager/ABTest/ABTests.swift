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

    static var showNPSSurvey = BoolABDynamicVar(key: "showNPSSurvey", defaultValue: false)
    static var nonStopProductDetail = BoolABDynamicVar(key: "nonStopProductDetail", defaultValue: false)
    static var onboardingPermissionsMode = IntABDynamicVar(key: "onboardingPermissionsMode", defaultValue: 0)
    static var incentivatePostingMode = IntABDynamicVar(key: "incentivatePostingMode", defaultValue: 0)
    static var messageOnFavorite = IntABDynamicVar(key: "messageOnFavorite", defaultValue: 0)
    static var expressChatMode = IntABDynamicVar(key: "expressChatMode", defaultValue: 0)
    static var interestedUsersMode = IntABDynamicVar(key: "interestedUsersMode", defaultValue: 0)
    static var filtersReorder = BoolABDynamicVar(key: "filtersReorder", defaultValue: false)
    static var halfCameraButton = BoolABDynamicVar(key: "halfCameraButton", defaultValue: true)

    static private var allVariables: [ABVariable] {
        return [showNPSSurvey, nonStopProductDetail, onboardingPermissionsMode,
                incentivatePostingMode, messageOnFavorite, expressChatMode, interestedUsersMode, filtersReorder, halfCameraButton]
    }

    static func registerVariables() {
        allVariables.forEach { $0.register() }
    }

    static func variablesUpdated() {
        trackingData.value = allVariables.flatMap{ $0.trackingData }
    }
}
