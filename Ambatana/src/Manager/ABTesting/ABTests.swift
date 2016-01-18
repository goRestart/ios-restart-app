//
//  ABTests.swift
//  LetGo
//
//  Created by Isaac Roldan on 20/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation

public struct ABTests {

    public static let nativePrePermissions = OptimizelyABLiveVariable.boolVariable("NativePrePermissions",
        boolValue: true)
    public static let prePermissionsActive = OptimizelyABLiveVariable.boolVariable("PrePermissionsActive_1.5.3+",
        boolValue: true)

    public static let nativePrePermissionAtList = OptimizelyABLiveVariable.boolVariable("nativePrePermissionAtList",
        boolValue: false)
    public static let alternativePermissionText = OptimizelyABLiveVariable.boolVariable("AlternativePermissionText",
        boolValue: false)


    public static let allValues = [ABTests.nativePrePermissions, ABTests.prePermissionsActive,
        ABTests.nativePrePermissionAtList, ABTests.alternativePermissionText]
}