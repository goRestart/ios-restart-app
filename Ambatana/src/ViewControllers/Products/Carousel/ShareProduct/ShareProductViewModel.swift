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

    var shareTypes: ShareType
    var delegate: ShareProductViewModelDelegate?
    weak var navigator: ProductDetailNavigator?

    var socialMessage: SocialMessage
    var link: String = "_uuuu"

    static func shareTypeForCountry(countryCode: String?) -> ShareType {
        let turkey = "tr"
        let defaultShareType: ShareType = [ShareType.SMS, ShareType.Email, ShareType.Facebook ,ShareType.FBMessenger, ShareType.Twitter,
                                ShareType.Whatsapp, ShareType.CopyLink]
        guard let countryCode = countryCode else { return defaultShareType }
        switch countryCode {
        case turkey:
            return [ShareType.Whatsapp, ShareType.Facebook, ShareType.Email ,ShareType.FBMessenger, ShareType.Twitter,
                    ShareType.SMS, ShareType.CopyLink]
        default:
            return defaultShareType
        }
    }

    convenience init(socialMessage: SocialMessage) {
        var systemCountryCode = ""
        if #available(iOS 10.0, *) {
            systemCountryCode = NSLocale.currentLocale().countryCode ?? ""
        } else {
            systemCountryCode = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as? String ?? ""
        }
        let countryCode = Core.locationManager.currentPostalAddress?.countryCode ?? systemCountryCode
        self.init(socialMessage: socialMessage, countryCode: countryCode)
    }

    init(socialMessage: SocialMessage, countryCode: String) {
        self.socialMessage = socialMessage // or get product and use SocialHelper.socialMessageWithProduct(product)
        self.shareTypes = ShareProductViewModel.shareTypeForCountry(countryCode)
        super.init()
    }

}
