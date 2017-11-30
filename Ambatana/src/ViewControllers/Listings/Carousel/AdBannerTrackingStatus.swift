//
//  AdBannerTrackingStatus.swift
//  LetGo
//
//  Created by Dídac on 31/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

/**
    This struct is used to save the ad banner tracking info to resend it again
    on the "more info show" event without need to request the banner again
 */

struct AdBannerTrackingStatus {
    let isMine: EventParameterBoolean
    let adShown: EventParameterBoolean
    let adType: EventParameterAdType?
    let queryType: EventParameterAdQueryType?
    let query: String?
    let visibility: EventParameterAdVisibility?
    let errorReason: EventParameterAdSenseRequestErrorReason?
}
