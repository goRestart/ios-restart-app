//
//  AdsRequester.swift
//  LetGo
//
//  Created by Dídac on 31/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import GoogleMobileAds

class AdsRequester {

    static let afsDefaultHostLanguage: String = "en"

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

    func makeAFShoppingRequestWithQuery(query: String?, width: CGFloat) -> GADDynamicHeightSearchRequest {
        let adsRequest = GADDynamicHeightSearchRequest()

        adsRequest.adTestEnabled = adTestModeActive

        if adTestModeActive {
            adsRequest.setAdvancedOptionValue(locale.languageCode ?? Constants.testglDefaultValue,
                                              forKey: Constants.testglKey)
            adsRequest.setAdvancedOptionValue(Constants.adtestValue, forKey: Constants.adtestKey)
        }

        adsRequest.query = query

        let stringWidth = String(Int(width))

        adsRequest.setAdvancedOptionValue(Constants.adTypeValue, forKey: Constants.adTypeKey)
        adsRequest.setAdvancedOptionValue(Constants.adHeightValue, forKey: Constants.adHeightKey)
        adsRequest.setAdvancedOptionValue(stringWidth, forKey: Constants.adWidthKey)

        return adsRequest
    }

    func makeAFSearchRequestWithQuery(query: String?, width: CGFloat) -> GADDynamicHeightSearchRequest {
        let adsRequest = GADDynamicHeightSearchRequest()

        adsRequest.adTestEnabled = adTestModeActive

        adsRequest.query = query

        let stringWidth = String(Int(width))

        adsRequest.hostLanguage = locale.languageCode ?? AdsRequester.afsDefaultHostLanguage
        adsRequest.numberOfAds = 1
        adsRequest.cssWidth = stringWidth     // Equivalent to "width" CSA parameter
        adsRequest.siteLinksExtensionEnabled = true
        adsRequest.sellerRatingsExtensionEnabled = true
        adsRequest.clickToCallExtensionEnabled = true
        
        return adsRequest
    }
}
