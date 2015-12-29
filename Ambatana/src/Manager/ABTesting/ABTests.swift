//
//  ABTests.swift
//  LetGo
//
//  Created by Isaac Roldan on 20/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation

public struct ABTests {

    public static let mainProductsJustImages = OptimizelyABLiveVariable.boolVariable("MainProductsJustImages",
        boolValue: false)

    public static let navBarTintColor = OptimizelyABLiveVariable.colorVariable("NavBarTintColor",
        colorValue: StyleHelper.primaryColor)
    public static let productsWithinFilterEnabled = OptimizelyABLiveVariable.boolVariable("ProductsWithinFilter",
        boolValue: true)
    public static let loginAfterSell = OptimizelyABLiveVariable.boolVariable("LoginAfterSell", boolValue: true)
    public static let nativePrePermissions = OptimizelyABLiveVariable.boolVariable("NativePrePermissions",
        boolValue: true)
    public static let prePermissionsActive = OptimizelyABLiveVariable.boolVariable("PrePermissionsActive",
        boolValue: true)
    public static let newPostingProcess = OptimizelyABLiveVariable.boolVariable("NewPostingProcess", boolValue: true)

    public static let allValues = [ABTests.mainProductsJustImages, ABTests.navBarTintColor,
        ABTests.productsWithinFilterEnabled, ABTests.loginAfterSell, ABTests.nativePrePermissions,
        ABTests.prePermissionsActive, ABTests.newPostingProcess]
}