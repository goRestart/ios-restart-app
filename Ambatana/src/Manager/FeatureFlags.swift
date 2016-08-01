//
//  FeatureFlags.swift
//  LetGo
//
//  Created by Eli Kohen on 18/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import FlipTheSwitch

struct FeatureFlags {
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

    static var userRatings: Bool {
        return FTSFlipTheSwitch.userRatings
    }
    
    static var showRelatedProducts: Bool {
        if FTSFlipTheSwitch.overridesABTests {
            return FTSFlipTheSwitch.showRelatedProducts
        }
        return ABTests.showRelatedProducts.boolValue()
    }
    
    static var showPriceOnListings: Bool {
        if FTSFlipTheSwitch.showPriceOnListings {
            return FTSFlipTheSwitch.showPriceOnListings
        }
        return ABTests.showPriceOnListings.boolValue()
    }
}

private extension FTSFlipTheSwitch {
    static var overridesABTests: Bool {
        return FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("overrides_abtests")
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

    static var userRatings: Bool {
        return FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("user_ratings")
    }
    
    static var showRelatedProducts: Bool {
        return FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("show_related_products")
    }
    
    static var showPriceOnListings: Bool {
        return FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("show_price_listings")
    }
}
