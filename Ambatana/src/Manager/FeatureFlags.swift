//
//  FeatureFlags.swift
//  LetGo
//
//  Created by Eli Kohen on 18/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import FlipTheSwitch

struct FeatureFlags {
    static var directChatActive: Bool {
        #if GOD_MODE
            if FTSFlipTheSwitch.overridesABTests {
                return FTSFlipTheSwitch.directChatActive
            }
        #endif
        return false
//        return ABTests.directChatActive.value
    }
}

private extension FTSFlipTheSwitch {
    static var overridesABTests: Bool {
        return FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("overrides_abtests")
    }

    static var directChatActive: Bool {
        return FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("direct_chat_active")
    }
}
