//
//  ProductPostedViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 14/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

protocol ProductPostedViewModelDelegate: class {
    func productPostedViewModelDidFinishPosting(viewModel: ProductPostedViewModel, correctly: Bool)
    func productPostedViewModelDidRestartPosting(viewModel: ProductPostedViewModel)
}

class ProductPostedViewModel: BaseViewModel {

    weak var delegate: ProductPostedViewModelDelegate?

    var mainButtonText: String?
    var mainText: String?
    var secondaryText: String?
    var shareInfo: SocialMessage?
    private var product: Product?

    init(postResult: ProductSaveServiceResult) {
        super.init()

        setup(postResult)
    }


    // MARK: - Public methods

    func onViewLoaded() {
        guard let product = product else { return }
        let trackerEvent = TrackerEvent.productSellConfirmation(product,
            user: MyUserManager.sharedInstance.myUser())
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    func closeActionPressed() {
        delegate?.productPostedViewModelDidFinishPosting(self, correctly: product != nil)

        guard let product = product else { return }
        let trackerEvent = TrackerEvent.productSellConfirmationClose(product,
            user: MyUserManager.sharedInstance.myUser())
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    func mainActionPressed() {
        delegate?.productPostedViewModelDidRestartPosting(self)

        guard let product = product else { return }
        let trackerEvent = TrackerEvent.productSellConfirmationPost(product,
            user: MyUserManager.sharedInstance.myUser())
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    func shareInEmail(){
        guard let product = product else { return }
        let trackerEvent = TrackerEvent.productSellConfirmationShare(product,
            user: MyUserManager.sharedInstance.myUser(), network: .Email)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    func shareInFacebook() {
        guard let product = product else { return }
        let trackerEvent = TrackerEvent.productSellConfirmationShare(product,
            user: MyUserManager.sharedInstance.myUser(), network: .Facebook)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    func shareInFacebookFinished(state: SocialShareState) {
        guard let product = product else { return }
        let trackerEvent: TrackerEvent
        switch state {
        case .Completed:
            trackerEvent = TrackerEvent.productSellConfirmationShareComplete(product,
                user: MyUserManager.sharedInstance.myUser(), network: .Facebook)
        case .Cancelled:
            trackerEvent = TrackerEvent.productSellConfirmationShareCancel(product,
                user: MyUserManager.sharedInstance.myUser(), network: .Facebook)
        case .Failed:
                return;
        }
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    func shareInFBMessenger() {
        guard let product = product else { return }
        let trackerEvent = TrackerEvent.productSellConfirmationShare(product,
            user: MyUserManager.sharedInstance.myUser(), network: .FBMessenger)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    func shareInFBMessengerFinished(state: SocialShareState) {
        guard let product = product else { return }
        let trackerEvent: TrackerEvent
        switch state {
        case .Completed:
            trackerEvent = TrackerEvent.productSellConfirmationShareComplete(product,
                user: MyUserManager.sharedInstance.myUser(), network: .FBMessenger)
        case .Cancelled:
            trackerEvent = TrackerEvent.productSellConfirmationShareCancel(product,
                user: MyUserManager.sharedInstance.myUser(), network: .FBMessenger)
        case .Failed:
            return;
        }
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    func shareInWhatsApp() {
        guard let product = product else { return }
        let trackerEvent = TrackerEvent.productSellConfirmationShare(product,
            user: MyUserManager.sharedInstance.myUser(), network: .Whatsapp)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }


    // MARK: - Private methods

    private func setup(postResult: ProductSaveServiceResult) {
        if let product = postResult.value {
            self.product = product
            mainText = LGLocalizedString.productPostConfirmationTitle
            secondaryText = LGLocalizedString.productPostConfirmationSubtitle
            mainButtonText = LGLocalizedString.productPostConfirmationAnotherButton
            shareInfo = SocialHelper.socialMessageWithTitle(LGLocalizedString.sellShareFbContent, product: product)
        }
        else {
            let error = postResult.error ?? .Internal
            let errorString: String
            switch error {
            case .Network:
                errorString = LGLocalizedString.productPostNetworkError
            default:
                errorString = LGLocalizedString.productPostGenericError
            }
            mainText = LGLocalizedString.commonErrorTitle.capitalizedString
            secondaryText = errorString
            mainButtonText = LGLocalizedString.productPostRetryButton
        }
    }

}