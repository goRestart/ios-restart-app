//
//  ShareProductViewModel.swift
//  LetGo
//
//  Created by Dídac on 26/10/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

protocol ShareProductViewModelDelegate {

}

class ShareProductViewModel: BaseViewModel {

    var shareTypes: [ShareType]
    var delegate: ShareProductViewModelDelegate?
    var shareFacadeDelegate: SocialShareFacadeDelegate?
    weak var navigator: ProductDetailNavigator?

    var socialMessage: SocialMessage
    var link: String {
        return socialMessage.copyLinkText ?? Constants.websiteURL
    }


    convenience init(shareFacadeDelegate: SocialShareFacadeDelegate, socialMessage: SocialMessage) {
        var systemCountryCode = ""
        if #available(iOS 10.0, *) {
            systemCountryCode = NSLocale.currentLocale().countryCode ?? ""
        } else {
            systemCountryCode = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as? String ?? ""
        }
        let countryCode = Core.locationManager.currentPostalAddress?.countryCode ?? systemCountryCode
        self.init(countryCode: countryCode, shareFacadeDelegate: shareFacadeDelegate, socialMessage: socialMessage)
    }

    // init w vm, locale & core.locationM

    init(countryCode: String, shareFacadeDelegate: SocialShareFacadeDelegate, socialMessage: SocialMessage) {
        self.socialMessage = socialMessage
        self.shareFacadeDelegate = shareFacadeDelegate
        self.shareTypes = ShareType.shareTypesForCountry(countryCode, maxButtons: 4, includeNative: true)
        super.init()
    }


    // MARK: - Public Methods


}
