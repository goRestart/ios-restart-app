//
//  ShareProductViewModel.swift
//  LetGo
//
//  Created by Dídac on 26/10/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit


protocol ShareProductViewModelDelegate: class {
    func vmShareFinishedWithMessage(message: String, state: SocialShareState)
    func vmViewControllerToShare() -> UIViewController
}

protocol ShareProductTrackerDelegate: class {
    func shareProductShareStarted(shareType: ShareType)
    func shareProductShareCompleted(shareType: ShareType, state: SocialShareState)
}

class ShareProductViewModel: BaseViewModel {

    var shareTypes: [ShareType]
    weak var delegate: ShareProductViewModelDelegate?
    weak var trackerDelegate: ShareProductTrackerDelegate?
    var socialSharer: SocialSharer?
    weak var navigator: ProductDetailNavigator?

    var socialMessage: SocialMessage
    var link: String {
        return socialMessage.copyLinkText ?? Constants.websiteURL
    }

    // MARK: - Lifecycle

    convenience init(socialMessage: SocialMessage) {
        self.init(socialSharer: SocialSharer(), socialMessage: socialMessage,
                  locale: NSLocale.currentLocale(), locationManager: Core.locationManager)
    }

    init(socialSharer: SocialSharer, socialMessage: SocialMessage, locale: NSLocale,
         locationManager: LocationManager) {

        let countryCode = locationManager.currentPostalAddress?.countryCode ?? locale.systemCountryCode

        self.socialMessage = socialMessage
        self.socialSharer = socialSharer
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
        trackerDelegate?.shareProductShareStarted(shareType)
    }

    func shareFinishedIn(shareType: ShareType, withState state: SocialShareState) {
        if let message = messageForShareIn(shareType, finishedWithState: state) {
            delegate?.vmShareFinishedWithMessage(message, state: state)
        }
        trackerDelegate?.shareProductShareCompleted(shareType, state: state)
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
        case (.CopyLink, .Completed):
            return LGLocalizedString.productShareCopylinkOk
        case (_, .Completed):
            return LGLocalizedString.productShareGenericOk
        default:
            break
        }
        return nil
    }
}
