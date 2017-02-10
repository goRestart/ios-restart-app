//
//  BumpUpFreeViewModel.swift
//  LetGo
//
//  Created by Dídac on 26/10/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit


class BumpUpFreeViewModel: BaseViewModel {
    let shareTypes: [ShareType]

    let product: Product
    let paymentItemId: String?
    let socialSharer: SocialSharer?
    fileprivate let tracker: Tracker

    weak var delegate: BaseViewModelDelegate?
    weak var navigator: BumpUpNavigator?

    var socialMessage: SocialMessage
    var title: String
    var subtitle: String

    fileprivate var purchasesShopper: PurchasesShopper?

    convenience init(product: Product, socialMessage: SocialMessage, paymentItemId: String?) {
        self.init(product: product, socialSharer: SocialSharer(), socialMessage: socialMessage,
                  paymentItemId: paymentItemId, locale: NSLocale.current, locationManager: Core.locationManager,
                  tracker: TrackerProxy.sharedInstance, purchasesShopper: LGPurchasesShopper.sharedInstance)
    }

    init(product: Product, socialSharer: SocialSharer, socialMessage: SocialMessage, paymentItemId: String?,
         locale: Locale, locationManager: LocationManager, tracker: Tracker, purchasesShopper: PurchasesShopper?) {
        self.product = product
        self.socialSharer = socialSharer
        self.tracker = tracker
        self.socialMessage = socialMessage
        self.purchasesShopper = purchasesShopper
        let countryCode = Core.locationManager.currentLocation?.countryCode ?? locale.lg_countryCode
        self.shareTypes = ShareType.shareTypesForCountry(countryCode, maxButtons: 4, nativeShare: .restricted)
        self.paymentItemId = paymentItemId
        self.title = LGLocalizedString.bumpUpViewFreeTitle
        self.subtitle = LGLocalizedString.bumpUpViewFreeSubtitle

        super.init()

        self.socialSharer?.delegate = self
    }

    // MARK: - Public Methods

    func closeActionPressed() {
        navigator?.bumpUpDidCancel()
    }

    func close(withCompletion completion: (() -> Void)?) {
        navigator?.bumpUpDidFinish(completion: completion)
    }
}


// MARK: - SocialShareFacadeDelegate

extension BumpUpFreeViewModel: SocialSharerDelegate {
    func shareStartedIn(_ shareType: ShareType) {
        let trackerEvent = TrackerEvent.productShare(product, network: shareType.trackingShareNetwork,
                                                     buttonPosition: .bumpUp, typePage: .productDetail,
                                                     isBumpedUp: EventParameterBoolean.falseParameter)
        tracker.trackEvent(trackerEvent)
    }

    func shareFinishedIn(_ shareType: ShareType, withState state: SocialShareState) {
        if let message = messageForShareIn(shareType, finishedWithState: state) {
            delegate?.vmShowAutoFadingMessage(message) { [weak self] in
                switch state {
                case .completed:
                    self?.close(withCompletion: {
                        self?.bumpUpProduct(withNetwork: shareType.trackingShareNetwork)
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

extension BumpUpFreeViewModel {
    func bumpUpProduct(withNetwork shareNetwork: EventParameterShareNetwork) {
        logMessage(.info, type: [.monetization], message: "TRY TO Bump FREE")
        guard let productId = product.objectId, let paymentItemId = self.paymentItemId else { return }
        purchasesShopper?.requestFreeBumpUpForProduct(productId: productId, withPaymentItemId: paymentItemId,
                                                      shareNetwork: shareNetwork)
    }
}
