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
    func vmShareFinishedWithMessage(message: String, state: SocialShareState)
    func vmViewControllerToShare() -> UIViewController
}

class ShareProductViewModel: BaseViewModel {

    var shareTypes: [ShareType]
    var delegate: ShareProductViewModelDelegate?
    var socialSharer: SocialSharer?
    weak var navigator: ProductDetailNavigator?

    var socialMessage: SocialMessage
    var link: String {
        return socialMessage.copyLinkText ?? Constants.websiteURL
    }


    convenience init(socialMessage: SocialMessage) {
        var systemCountryCode = ""
        if #available(iOS 10.0, *) {
            systemCountryCode = NSLocale.currentLocale().countryCode ?? ""
        } else {
            systemCountryCode = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as? String ?? ""
        }
        let countryCode = Core.locationManager.currentPostalAddress?.countryCode ?? systemCountryCode
        self.init(countryCode: countryCode, shareFacade: SocialSharer(), socialMessage: socialMessage)
    }

    // init w vm, locale & core.locationM

    init(countryCode: String, shareFacade: SocialSharer, socialMessage: SocialMessage) {
        self.socialMessage = socialMessage
        self.socialSharer = shareFacade
        self.shareTypes = ShareType.shareTypesForCountry(countryCode, maxButtons: 4, includeNative: true)
        super.init()

        self.socialSharer?.delegate = self
    }

    // MARK: - Public Methods

    func copyLink() {
        guard let vc = delegate?.vmViewControllerToShare() else { return }
        socialSharer?.share(socialMessage, shareType: .CopyLink, viewController: vc)
    }
}


// MARK: - SocialShareFacadeDelegate

extension ShareProductViewModel: SocialSharerDelegate {
    func shareStartedIn(shareType: ShareType) {

//        trackShareStarted(shareType, buttonPosition: buttonPosition)
    }

    func shareFinishedIn(shareType: ShareType, withState state: SocialShareState) {

        if let message = messageForShareIn(shareType, finishedWithState: state) {
            delegate?.vmShareFinishedWithMessage(message, state: state)
        }

//        trackShareCompleted(shareType, buttonPosition: buttonPosition, state: state)
    }

    private func messageForShareIn(shareType: ShareType, finishedWithState state: SocialShareState) -> String? {
        switch (shareType, state) {
        case (.Email, .Completed):
            return LGLocalizedString.productShareGenericOk
        case (.Email, .Failed):
            return LGLocalizedString.productShareEmailError
        case (.Facebook, .Failed):
            return LGLocalizedString.sellSendErrorSharingFacebook
        case (.FBMessenger, .Failed):
            return LGLocalizedString.sellSendErrorSharingFacebook
        case (.SMS, .Completed):
            return LGLocalizedString.productShareSmsOk
        case (.SMS, .Failed):
            return LGLocalizedString.productShareSmsError
        default:
            break
        }
        return nil
    }
}
