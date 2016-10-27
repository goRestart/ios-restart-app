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
    var shareDelegate: SocialShareViewDelegate?
    weak var navigator: ProductDetailNavigator?

    var socialMessage: SocialMessage?
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

    convenience init(productVM: ProductViewModel) {
        var systemCountryCode = ""
        if #available(iOS 10.0, *) {
            systemCountryCode = NSLocale.currentLocale().countryCode ?? ""
        } else {
            systemCountryCode = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as? String ?? ""
        }
        let countryCode = Core.locationManager.currentPostalAddress?.countryCode ?? systemCountryCode
        self.init(productVM: productVM, countryCode: countryCode)
    }

    init(productVM: ProductViewModel, countryCode: String) {
        self.shareDelegate = productVM
        self.socialMessage = productVM.socialMessage.value
        self.shareTypes = ShareProductViewModel.shareTypeForCountry(countryCode)
        super.init()
    }

}
