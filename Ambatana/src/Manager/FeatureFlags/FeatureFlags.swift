//
//  FeatureFlags.swift
//  LetGo
//
//  Created by Eli Kohen on 18/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import bumper

struct FeatureFlags {
    static func setup() {
        Bumper.initialize()
    }

    static var websocketChat: Bool = {
        if Bumper.enabled {
            return Bumper.websocketChat
        }
        return false
    }()
    
    static var notificationsSection: Bool = {
        if Bumper.enabled {
            return Bumper.notificationsSection
        }
        return false
    }()

    static var userRatings: Bool {
        if Bumper.enabled {
            return Bumper.userRatings
        }
        return false
    }

    static var directStickersOnProduct: Bool {
        if Bumper.enabled {
            return Bumper.directStickersOnProduct
        }
        return ABTests.directStickersOnProduct.value
    }
    
    static var showNPSSurvey: Bool {
        if Bumper.enabled {
            return Bumper.showNPSSurvey
        }
        return ABTests.showNPSSurvey.value
    }

    static var postingDetailsMode: PostingDetailsMode {
        if Bumper.enabled {
            return Bumper.postingDetailsMode
        }
        return PostingDetailsMode.fromPosition(ABTests.postingDetailsMode.value)
    }
    
    static var appInviteFeedMode: AppInviteListingMode {
        if Bumper.enabled {
            return Bumper.appInviteListingMode
        }
        return AppInviteListingMode.fromPosition(ABTests.appInviteFeedMode.value)
    }

    static var profileVerifyOneButton: Bool {
        if Bumper.enabled {
            return Bumper.profileBuildTrustButton
        }
        return ABTests.profileVerifyOneButton.value
    }

    static var nonStopProductDetail: Bool {
        if Bumper.enabled {
            return Bumper.nonStopProductDetail
        }
        return ABTests.nonStopProductDetail.value
    }

    static var onboardinPermissionsMode: OnboardingPermissionsMode {
        if Bumper.enabled {
            return Bumper.onboardingPermissionsMode
        }
        return OnboardingPermissionsMode.fromPosition(ABTests.onboardingPermissionsMode.value)
    }

    static var incentivizePostingMode: IncentivizePostingMode {
        if Bumper.enabled {
            return Bumper.incentivizePostingMode
        }
        return IncentivizePostingMode.fromPosition(ABTests.incentivatePostingMode.value)
    }
}
