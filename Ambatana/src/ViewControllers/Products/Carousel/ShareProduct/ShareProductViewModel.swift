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
}


class ShareProductViewModel: BaseViewModel {
    let shareTypes: [ShareType]

    let product: Product
    let socialSharer: SocialSharer?
    private let tracker: Tracker

    weak var delegate: ShareProductViewModelDelegate?
    weak var navigator: ProductDetailNavigator?

    var socialMessage: SocialMessage
    var link: String {
        return socialMessage.copyLinkText ?? Constants.websiteURL
    }

    convenience init(product: Product, socialMessage: SocialMessage) {
        self.init(product: product, socialSharer: SocialSharer(), socialMessage: socialMessage,
                  locale: NSLocale.currentLocale(), locationManager: Core.locationManager, tracker: TrackerProxy.sharedInstance)
    }

    init(product: Product, socialSharer: SocialSharer, socialMessage: SocialMessage, locale: NSLocale,
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
        socialSharer?.share(socialMessage, shareType: .CopyLink, viewController: vc)
    }
}


// MARK: - SocialShareFacadeDelegate

extension ShareProductViewModel: SocialSharerDelegate {
    func shareStartedIn(shareType: ShareType) {
        let trackerEvent = TrackerEvent.productShare(product, network: shareType.trackingShareNetwork,
                                                     buttonPosition: .Top, typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareFinishedIn(shareType: ShareType, withState state: SocialShareState) {
        if let message = messageForShareIn(shareType, finishedWithState: state) {
            delegate?.vmShowAutoFadingMessage(message) { [weak self] in
                switch state {
                case .Completed:
                    self?.delegate?.vmDismiss(nil)
                case .Cancelled, .Failed:
                    break
                }
            }
        }

        let event: TrackerEvent?
        switch state {
        case .Completed:
            event = TrackerEvent.productShareComplete(product, network: shareType.trackingShareNetwork,
                                                      typePage: .ProductDetail)
        case .Failed:
            event = nil
        case .Cancelled:
            event = TrackerEvent.productShareCancel(product, network: shareType.trackingShareNetwork,
                                                    typePage: .ProductDetail)
        }
        if let event = event {
            tracker.trackEvent(event)
        }
    }

    private func messageForShareIn(shareType: ShareType, finishedWithState state: SocialShareState) -> String? {
        switch (shareType, state) {
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
