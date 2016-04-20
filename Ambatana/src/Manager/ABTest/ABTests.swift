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
}
