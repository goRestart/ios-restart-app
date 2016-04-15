//
//  ABTests.swift
//  LetGo
//
//  Created by Dídac on 12/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Taplytics

public struct ABTests {

    static var directChatActive: BoolABDynamicVar {
        return BoolABDynamicVar(key: "direct_chat_active", type: .Bool, defaultValue: false)
    }


    #if DEBUG

    // Those ABtests are defined in taplytics's letgo_sandbox
    // Kept here for testing purposes until Taplytics is fully implemented

    static var testVar1: BoolABDynamicVar {
        return BoolABDynamicVar(key: "test_var_1", type: .Bool, defaultValue: false)
    }

    static var testStringVar: StringABDynamicVar {
        return StringABDynamicVar(key: "test_string_var", type: .String, defaultValue: "default value for string var")
    }

    #endif
}
