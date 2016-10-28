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

    var socialMessage: SocialMessage?
    var link: String {
        return socialMessage?.copyLinkText ?? Constants.websiteURL
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

    // init w vm, locale & core.locationM

    init(productVM: ProductViewModel, countryCode: String) {
        self.shareDelegate = productVM
        self.socialMessage = productVM.socialMessage.value
        self.shareTypes = ShareType.shareTypesForCountry(countryCode, maxButtons: 4, includeNative: true)
        super.init()
    }


    // MARK: - Public Methods


}
