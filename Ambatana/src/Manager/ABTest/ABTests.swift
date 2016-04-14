//
//  ABTests.swift
//  LetGo
//
//  Created by Dídac on 12/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Taplytics

public struct ABTests {

    #if DEBUG

    // Those ABtests are defined in taplytics's letgo_sandbox
    // Kept here for testing purposes until Taplytics is fully implemented

    static var testVar1: BoolABDynamicVar {
        return BoolABDynamicVar(key: "test_var_1", type: .Bool, value: false)
    }

    static var testStringVar: StringABDynamicVar {
        return StringABDynamicVar(key: "test_string_var", type: .String, value: "default value for string var")
    }

    #endif
}
