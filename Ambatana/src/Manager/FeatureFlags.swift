//
//  FeatureFlags.swift
//  LetGo
//
//  Created by Eli Kohen on 18/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import FlipTheSwitch

enum PostingDetailsMode: Int {
    case Old = 0
    case AllInOne = 1
    case Steps = 2
}

struct FeatureFlags {
    static var websocketChat: Bool = {
        return FTSFlipTheSwitch.websocketChat
    }()
    
    static var notificationsSection: Bool = {
        if FTSFlipTheSwitch.overridesABTests {
            return FTSFlipTheSwitch.notificationsSection
        }
        return false
    }()

    static var userRatings: Bool {
        return FTSFlipTheSwitch.userRatings
    }

    static var bigFavoriteIcon: Bool {
        if FTSFlipTheSwitch.overridesABTests {
            return FTSFlipTheSwitch.bigFavoriteIcon
        }
        return ABTests.bigFavoriteIcon.value
    }
    
    static var showRelatedProducts: Bool {
        if FTSFlipTheSwitch.overridesABTests {
            return FTSFlipTheSwitch.showRelatedProducts
        }
        return ABTests.showRelatedProducts.value
    }
    
    static var showPriceOnListings: Bool {
        if FTSFlipTheSwitch.overridesABTests {
            return FTSFlipTheSwitch.showPriceOnListings
        }
        return ABTests.showPriceOnListings.value
    }

    static var directStickersOnProduct: Bool {
        if FTSFlipTheSwitch.overridesABTests {
            return FTSFlipTheSwitch.directStickersOnProduct
        }
        return ABTests.directStickersOnProduct.value
    }
    
    static var showNPSSurvey: Bool {
        if FTSFlipTheSwitch.overridesABTests {
            return FTSFlipTheSwitch.showNPSSurvey
        }
        return ABTests.showNPSSurvey.value
    }

    static var postingDetailsMode: PostingDetailsMode {
        if FTSFlipTheSwitch.overridesABTests {
            if FTSFlipTheSwitch.newPostDetails {
                return FTSFlipTheSwitch.newPostDetailsSteps ? .Steps : .AllInOne
            } else {
                return .Old
            }
        }
        return PostingDetailsMode(rawValue: ABTests.postingDetailsMode.value) ?? .Old
    }
    
    static var showInviteHeartIcon: Bool = {
        if FTSFlipTheSwitch.overridesABTests {
            return FTSFlipTheSwitch.showInviteHeartIcon
        }
        return ABTests.showInviteHeartIcon.value
    }()

    static var profileVerifyOneButton: Bool = {
        if FTSFlipTheSwitch.overridesABTests {
            return FTSFlipTheSwitch.profileVerifyOneButton
        }
        return ABTests.profileVerifyOneButton.value
    }()
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
    
    static var userRatings: Bool {
        return FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("user_ratings")
    }

    static var bigFavoriteIcon: Bool {
        return FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("big_favorite_icon")
    }
    
    static var showRelatedProducts: Bool {
        return FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("show_related_products")
    }
    
    static var showPriceOnListings: Bool {
        return FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("show_price_listings")
    }

    static var directStickersOnProduct: Bool {
        return FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("direct_stickers_on_product")
    }

    static var newPostDetails: Bool {
        return FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("new_post_details")
    }

    static var newPostDetailsSteps: Bool {
        return FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("new_post_details_steps")
    }
    
    static var showInviteHeartIcon: Bool {
        return FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("show_invite_heart_icon")
    }

    static var showNPSSurvey: Bool {
        return FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("show_nps_survey")
    }

    static var profileVerifyOneButton: Bool {
        return FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("profile_verify_one_button")
    }
}
