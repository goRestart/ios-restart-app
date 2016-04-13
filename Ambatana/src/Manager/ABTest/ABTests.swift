//
//  ABTests.swift
//  LetGo
//
//  Created by Dídac on 12/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

public struct ABTests {

    #if DEBUG

    // Those ABtests are defined in taplytics's letgo_sandbox
    // Kept here for testing purposes until Taplytics is fully implemented

    static var testVar1: TaplyticsABDynamicVar {
        return TaplyticsABDynamicVar.boolVariable("test_var_1", boolValue: false)
    }

    static var testStringVar: TaplyticsABDynamicVar {
        return TaplyticsABDynamicVar.stringVariable("test_string_var", stringValue: "default value for string var")
    }

    #endif
}
