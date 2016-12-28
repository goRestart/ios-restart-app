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
    func vmDidFinishSharing()
}

class ShareProductViewModel: BaseViewModel {
    let shareTypes: [ShareType]

    let product: Product
    let socialSharer: SocialSharer?
    private let tracker: Tracker

    weak var delegate: ShareProductViewModelDelegate?
    weak var navigator: ShareProductNavigator?

    var socialMessage: SocialMessage
    var title: String
    var subtitle: String
    var link: String {
        return socialMessage.copyLinkText ?? Constants.websiteURL
    }
    var purchasesShopper: PurchasesShopper?

    convenience init(product: Product, socialMessage: SocialMessage, bumpUp: Bool) {
        let purchasesShopper: PurchasesShopper? = bumpUp ? PurchasesShopper.sharedInstance : nil
        self.init(product: product, socialSharer: SocialSharer(), socialMessage: socialMessage, bumpUp: bumpUp,
                  locale: NSLocale.currentLocale(), locationManager: Core.locationManager,
                  tracker: TrackerProxy.sharedInstance, purchasesShopper: purchasesShopper)
    }

    init(product: Product, socialSharer: SocialSharer, socialMessage: SocialMessage, bumpUp: Bool,
         locale: NSLocale, locationManager: LocationManager, tracker: Tracker, purchasesShopper: PurchasesShopper?) {
        self.product = product
        self.socialSharer = socialSharer
        self.tracker = tracker
        self.socialMessage = socialMessage
        self.purchasesShopper = purchasesShopper
        let countryCode = Core.locationManager.currentPostalAddress?.countryCode ?? locale.lg_countryCode
        self.shareTypes = ShareType.shareTypesForCountry(countryCode, maxButtons: 4, includeNative: true)
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
        socialSharer?.share(socialMessage, shareType: .CopyLink, viewController: vc)
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
    func shareStartedIn(shareType: ShareType) {
    }

    func shareFinishedIn(shareType: ShareType, withState state: SocialShareState) {
        if let message = messageForShareIn(shareType, finishedWithState: state) {
            delegate?.vmShowAutoFadingMessage(message) { [weak self] in
                switch state {
                case .Completed:
                    self?.delegate?.vmDidFinishSharing()
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


// MARK: Bump Up Methods

extension ShareProductViewModel {
    func bumpUpProduct() {
        print("TRY TO Bump FREE")
        guard let productId = product.objectId else { return }
        purchasesShopper?.requestFreeBumpUpForProduct(productId)
    }
}
