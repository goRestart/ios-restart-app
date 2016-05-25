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
            if FTSFlipTheSwitch.overridesABTests {
                return FTSFlipTheSwitch.directChatActive
            }
        return ABTests.directChatActive.value
    }

    static var snapchatProductDetail: Bool {
            if FTSFlipTheSwitch.overridesABTests {
                return FTSFlipTheSwitch.snapchatProductDetail
            }
        return ABTests.snapchatProductDetail.value
    }
    
    static var websocketChat: Bool {
        return FTSFlipTheSwitch.websocketChat
    }

    static var notificationsSection: Bool {
        if FTSFlipTheSwitch.overridesABTests {
            return FTSFlipTheSwitch.notificationsSection
        }
        return false
    }

    static var indexProductsTrendingFirst24h: Bool {
        return FTSFlipTheSwitch.indexProductsTrendingFirst24h
    }
}

private extension FTSFlipTheSwitch {
    static var overridesABTests: Bool {
        return FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("overrides_abtests")
    }

    static var directChatActive: Bool {
        return FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("direct_chat_active")
    }

    static var snapchatProductDetail: Bool {
        return FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("snapchat_product_detail")
    }
    
    static var websocketChat: Bool {
        return FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("websocket_chat")
    }

    static var notificationsSection: Bool {
        return FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("notifications_replaces_categories")
    }

    static var indexProductsTrendingFirst24h: Bool {
        return FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("index_products_trending_first_24h")
    }
}
