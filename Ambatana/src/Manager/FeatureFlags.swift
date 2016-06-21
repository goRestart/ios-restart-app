//
//  FeatureFlags.swift
//  LetGo
//
//  Created by Eli Kohen on 18/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import FlipTheSwitch

enum ProductDetailVersion: Int {
    case Original = 0
    case OriginalWithoutOffer = 1
    case Snapchat = 2
}

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
      
    static var mainProducts3Columns: Bool {
        if FTSFlipTheSwitch.overridesABTests {
            return FTSFlipTheSwitch.mainProducts3Columns
        }
        return ABTests.mainProducts3Columns.value
    }
    
    static var productDetailVersion: ProductDetailVersion {
        if FTSFlipTheSwitch.overridesABTests {
            if FTSFlipTheSwitch.snapchatProductDetail {
                return .Snapchat
            } else if FTSFlipTheSwitch.productDetailShowOfferButton {
                return .Original
            } else {
                return .OriginalWithoutOffer
            }
        }
        return ProductDetailVersion(rawValue: Int(ABTests.productDetailVersion.value.intValue)) ?? .Original
    }
    
    static var ignoreMyUserVerification: Bool {
        return FTSFlipTheSwitch.ignoreMyUserVerification
    }

    static var sellOnStartupAfterPosting: Bool {
        if FTSFlipTheSwitch.overridesABTests {
            return FTSFlipTheSwitch.sellOnStartupAfterPosting
        }
        return ABTests.sellOnStartupAfterPosting.value
    }
}

private extension FTSFlipTheSwitch {
    static var overridesABTests: Bool {
        return FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("overrides_abtests")
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

    static var mainProducts3Columns: Bool {
        return FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("main_products_3_columns")
    }
    
    static var productDetailShowOfferButton: Bool {
        return FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("product_detail_offer_button")
    }
    
    static var ignoreMyUserVerification: Bool {
        return FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("ignore_myuser_verification")
    }

    static var sellOnStartupAfterPosting: Bool {
        return FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("sell_on_startup_after_posting")
    }
}
