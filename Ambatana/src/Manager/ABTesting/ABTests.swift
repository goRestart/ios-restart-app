//
//  ABTests.swift
//  LetGo
//
//  Created by Isaac Roldan on 20/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation

public struct ABTests {

    public static let loginAfterSell = OptimizelyABLiveVariable.boolVariable("LoginAfterSell", boolValue: true)
    public static let nativePrePermissions = OptimizelyABLiveVariable.boolVariable("NativePrePermissions",
        boolValue: true)
    public static let prePermissionsActive = OptimizelyABLiveVariable.boolVariable("PrePermissionsActive",
        boolValue: true)

    public static let newPostingProcess = OptimizelyABLiveVariable.boolVariable("NewPostingProcess", boolValue: true)

    public static let nativePrePermissionAtList = OptimizelyABLiveVariable.boolVariable("nativePrePermissionAtList",
        boolValue: false)
    public static let alternativePermissionText = OptimizelyABLiveVariable.boolVariable("AlternativePermissionText",
        boolValue: false)


    public static let allValues = [ABTests.loginAfterSell, ABTests.nativePrePermissions, ABTests.prePermissionsActive,
        ABTests.nativePrePermissionAtList, ABTests.alternativePermissionText, ABTests.newPostingProcess]
}