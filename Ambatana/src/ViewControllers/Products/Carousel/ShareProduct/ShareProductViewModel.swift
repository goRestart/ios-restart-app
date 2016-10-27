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
    var shareDelegate: SocialShareViewDelegate?
    weak var navigator: ProductDetailNavigator?

//    var socialMessage: SocialMessage?
//    var link: String {
//        return socialMessage?.copyLinkText ?? Constants.websiteURL
//    }

    var title: String {
        return "_SHARING IS WINNING!"
    }
    var subTitle: String {
        return "_Did you know that those who share their products are 100% more likely to be awesome?"
    }

    convenience init(productVM: ProductViewModel) {
        var systemCountryCode = ""
        if #available(iOS 10.0, *) {
            systemCountryCode = NSLocale.currentLocale().countryCode ?? ""
        } else {
            systemCountryCode = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as? String ?? ""
        }
        let countryCode = Core.locationManager.currentPostalAddress?.countryCode ?? systemCountryCode
        self.init(countryCode: countryCode)
    }

    // init w vm, locale & core.locationM

    init(countryCode: String) {
//        self.socialMessage = productVM.socialMessage.value
        self.shareTypes = ShareType.shareTypesForCountry(countryCode, maxButtons: 4, includeNative: true)
        super.init()
    }


    // MARK: - Public Methods


}
