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
    fileprivate let tracker: Tracker

    weak var delegate: ShareProductViewModelDelegate?
    weak var navigator: ShareProductNavigator?

    var socialMessage: SocialMessage
    var title: String
    var subtitle: String
    var link: String {
        return socialMessage.copyLinkText
    }

    fileprivate var purchasesShopper: PurchasesShopper?
    fileprivate var bumpUp: Bool

    convenience init(product: Product, socialMessage: SocialMessage, bumpUp: Bool) {
    let purchasesShopper: PurchasesShopper? = bumpUp ? PurchasesShopper.sharedInstance : nil
        self.init(product: product, socialSharer: SocialSharer(), socialMessage: socialMessage, bumpUp: bumpUp,
                  locale: NSLocale.current, locationManager: Core.locationManager, tracker: TrackerProxy.sharedInstance,
                purchasesShopper: purchasesShopper)
    }

    init(product: Product, socialSharer: SocialSharer, socialMessage: SocialMessage, bumpUp: Bool, locale: Locale,
         locationManager: LocationManager, tracker: Tracker, purchasesShopper: PurchasesShopper?) {
        self.product = product
        self.socialSharer = socialSharer
        self.tracker = tracker
        self.socialMessage = socialMessage
        self.purchasesShopper = purchasesShopper
        let countryCode = Core.locationManager.currentPostalAddress?.countryCode ?? locale.lg_countryCode
        self.shareTypes = ShareType.shareTypesForCountry(countryCode, maxButtons: 4, includeNative: true)
        self.bumpUp = bumpUp
        if bumpUp {
            self.title = LGLocalizedString.bumpUpViewFreeTitle
            self.subtitle = LGLocalizedString.bumpUpViewFreeSubtitle
        } else {
            self.title = LGLocalizedString.productShareFullscreenTitle
            self.subtitle = LGLocalizedString.productShareFullscreenSubtitle
        }
        super.init()

        self.socialSharer?.delegate = self
    }

    // MARK: - Public Methods

    func copyLink() {
        guard let vc = delegate?.vmViewControllerToShare() else { return }
        socialSharer?.share(socialMessage, shareType: .copyLink, viewController: vc)
    }
    
    func closeActionPressed() {
        close(withCompletion: nil)
    }

    func close(withCompletion completion: (() -> Void)?) {
        if let navigator = navigator {
            navigator.closeShareProduct(product)
        } else {
            delegate?.vmDismiss(completion)
        }
    }
}


// MARK: - SocialShareFacadeDelegate

extension ShareProductViewModel: SocialSharerDelegate {
    func shareStartedIn(_ shareType: ShareType) {
        // in the "share after posting" there is no track of a share start event
        guard bumpUp else { return }
        let trackerEvent = TrackerEvent.productShare(product, network: shareType.trackingShareNetwork,
                                                     buttonPosition: .bumpUp, typePage: .productDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareFinishedIn(_ shareType: ShareType, withState state: SocialShareState) {
        if let message = messageForShareIn(shareType, finishedWithState: state) {
            delegate?.vmShowAutoFadingMessage(message) { [weak self] in
                switch state {
                case .completed:
                    self?.close(withCompletion: {
                            guard let isBumpUp = self?.bumpUp, isBumpUp else { return }
                            self?.bumpUpProduct()
                    })
                case .cancelled, .failed:
                    break
                }
            }
        }

        let event: TrackerEvent?
        switch state {
        case .completed:
            event = TrackerEvent.productShareComplete(product, network: shareType.trackingShareNetwork,
                                                      typePage: .productDetail)
        case .failed:
            event = nil
        case .cancelled:
            event = TrackerEvent.productShareCancel(product, network: shareType.trackingShareNetwork,
                                                    typePage: .productDetail)
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


// MARK: Bump Up Methods

extension ShareProductViewModel {
    func bumpUpProduct() {
        logMessage(.info, type: [.monetization], message: "TRY TO Bump FREE")
        guard let productId = product.objectId else { return }
        purchasesShopper?.requestFreeBumpUpForProduct(productId: productId)
    }
}
