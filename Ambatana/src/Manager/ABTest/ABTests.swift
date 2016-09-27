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
    static var profileVerifyOneButton = BoolABDynamicVar(key: "profileVerifyOneButton", defaultValue: false)
    static var nonStopProductDetail = BoolABDynamicVar(key: "nonStopProductDetail", defaultValue: false)
    static var onboardingPermissionsMode = IntABDynamicVar(key: "onboardingPermissionsMode", defaultValue: 0)
    static var incentivatePostingMode = IntABDynamicVar(key: "incentivatePostingMode", defaultValue: 0)

    static private var allVariables: [ABVariable] {
        return [showNPSSurvey, profileVerifyOneButton, nonStopProductDetail, onboardingPermissionsMode,
                incentivatePostingMode]
    }

    static func registerVariables() {
        allVariables.forEach { $0.register() }
    }

    static func variablesUpdated() {
        trackingData.value = allVariables.flatMap{ $0.trackingData }
    }
}
