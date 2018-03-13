//
//  AdsRequester.swift
//  LetGo
//
//  Created by Dídac on 31/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import GoogleMobileAds

class AdsRequester {

    static let testglKey: String = "testgl"
    static let testglDefaultValue: String = "en"
    static let adtestKey: String = "adtest"
    static let adtestValue: String = "on"
    static let adTypeKey: String = "adType"
    static let adTypeValue: String = "plas"
    static let adHeightKey: String = "height"
    static let adHeightValue: String = "200"
    static let adWidthKey: String = "width"

    let locale: Locale
    let featureFlags: FeatureFlaggeable

    var adTestModeActive: Bool {
        return EnvironmentProxy.sharedInstance.adTestModeActive
    }

    convenience init() {
        self.init(locale: Locale.current, featureFlags: FeatureFlags.sharedInstance)
    }

    init(locale: Locale, featureFlags: FeatureFlaggeable) {
        self.locale = locale
        self.featureFlags = featureFlags
    }


    // MARK: Public methods

    func makeAFShoppingRequestWithQuery(query: String?, width: CGFloat, channel: String?) -> GADDynamicHeightSearchRequest {
        let adsRequest = GADDynamicHeightSearchRequest()

        adsRequest.adTestEnabled = adTestModeActive

        if adTestModeActive {
            adsRequest.setAdvancedOptionValue(locale.languageCode ?? AdsRequester.testglDefaultValue,
                                              forKey: AdsRequester.testglKey)
            adsRequest.setAdvancedOptionValue(AdsRequester.adtestValue, forKey: AdsRequester.adtestKey)
        }

        adsRequest.query = query
        adsRequest.channel = channel

        let stringWidth = String(Int(width))

        adsRequest.setAdvancedOptionValue(AdsRequester.adTypeValue, forKey: AdsRequester.adTypeKey)
        adsRequest.setAdvancedOptionValue(AdsRequester.adHeightValue, forKey: AdsRequester.adHeightKey)
        adsRequest.setAdvancedOptionValue(stringWidth, forKey: AdsRequester.adWidthKey)

        return adsRequest
    }
}