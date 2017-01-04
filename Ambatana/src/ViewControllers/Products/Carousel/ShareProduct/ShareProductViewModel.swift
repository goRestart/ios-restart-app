//
//  ShareProductViewModel.swift
//  LetGo
//
//  Created by Dídac on 26/10/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit


protocol ShareProductViewModelDelegate: BaseViewModelDelegate {
    func vmViewControllerToShare() -> UIViewController
    func viewControllerShouldClose()
}


class ShareProductViewModel: BaseViewModel {
    let shareTypes: [ShareType]

    let product: Product
    let socialSharer: SocialSharer?
    private let tracker: Tracker

    weak var delegate: ShareProductViewModelDelegate?
    weak var navigator: ShareProductNavigator?

    var socialMessage: SocialMessage
    var link: String {
        return socialMessage.copyLinkText
    }

    convenience init(product: Product, socialMessage: SocialMessage) {
        self.init(product: product, socialSharer: SocialSharer(), socialMessage: socialMessage,
                  locale: NSLocale.current, locationManager: Core.locationManager, tracker: TrackerProxy.sharedInstance)
    }

    init(product: Product, socialSharer: SocialSharer, socialMessage: SocialMessage, locale: Locale,
         locationManager: LocationManager, tracker: Tracker) {
        self.product = product
        self.socialSharer = socialSharer
        self.tracker = tracker
        self.socialMessage = socialMessage
        let countryCode = Core.locationManager.currentPostalAddress?.countryCode ?? locale.lg_countryCode
        self.shareTypes = ShareType.shareTypesForCountry(countryCode, maxButtons: 4, includeNative: true)
        super.init()

        self.socialSharer?.delegate = self
    }

    // MARK: - Public Methods

    func copyLink() {
        guard let vc = delegate?.vmViewControllerToShare() else { return }
        socialSharer?.share(socialMessage, shareType: .copyLink, viewController: vc)
    }
    
    func closeActionPressed() {
        if let navigator = navigator {
            navigator.closeShareProduct(product)
        } else {
            delegate?.viewControllerShouldClose()
        }
    }
}


// MARK: - SocialShareFacadeDelegate

extension ShareProductViewModel: SocialSharerDelegate {
    func shareStartedIn(_ shareType: ShareType) {
    }

    func shareFinishedIn(_ shareType: ShareType, withState state: SocialShareState) {
        if let message = messageForShareIn(shareType, finishedWithState: state) {
            delegate?.vmShowAutoFadingMessage(message) { [weak self] in
                switch state {
                case .completed:
                    self?.delegate?.vmDismiss(nil)
                case .cancelled, .failed:
                    break
                }
            }
        }

        let event: TrackerEvent?
        switch state {
        case .completed:
            event = TrackerEvent.productShareComplete(product, network: shareType.trackingShareNetwork,
                                                      typePage: .ProductDetail)
        case .failed:
            event = nil
        case .cancelled:
            event = TrackerEvent.productShareCancel(product, network: shareType.trackingShareNetwork,
                                                    typePage: .ProductDetail)
        }
        if let event = event {
            tracker.trackEvent(event)
        }
    }

    private func messageForShareIn(_ shareType: ShareType, finishedWithState state: SocialShareState) -> String? {
        switch (shareType, state) {
        case (.email, .failed):
            return LGLocalizedString.productShareEmailError
        case (.facebook, .failed):
            return LGLocalizedString.sellSendErrorSharingFacebook
        case (.fbMessenger, .failed):
            return LGLocalizedString.sellSendErrorSharingFacebook
        case (.sms, .completed):
            return LGLocalizedString.productShareSmsOk
        case (.sms, .failed):
            return LGLocalizedString.productShareSmsError
        case (.copyLink, .completed):
            return LGLocalizedString.productShareCopylinkOk
        case (_, .completed):
            return LGLocalizedString.productShareGenericOk
        default:
            break
        }
        return nil
    }
}
