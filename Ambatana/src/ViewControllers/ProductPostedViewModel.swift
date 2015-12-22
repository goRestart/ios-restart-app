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
    func productPostedViewModelDidEditPosting(viewModel: ProductPostedViewModel,
        editViewModel: EditSellProductViewModel)
    func productPostedViewModelDidRestartPosting(viewModel: ProductPostedViewModel)
}

class ProductPostedViewModel: BaseViewModel {

    weak var delegate: ProductPostedViewModelDelegate?

    var mainButtonText: String?
    var mainText: String?
    var secondaryText: String?
    var shareInfo: SocialMessage?
    var success: Bool {
        return product != nil
    }
    private var product: Product?
    private var postProductError: EventParameterPostProductError?
    private var user: MyUser? {
        return MyUserRepository.sharedInstance.myUser
    }

    init(postResult: ProductSaveServiceResult) {
        super.init()

        setup(postResult)
    }


    // MARK: - Public methods

    func onViewLoaded() {
        if let product = product {
            trackEvent(TrackerEvent.productSellConfirmation(product, user: user))
        } else if let error = postProductError {
            trackEvent(TrackerEvent.productSellError(user, error: error))
        }
    }

    func closeActionPressed() {
        delegate?.productPostedViewModelDidFinishPosting(self, correctly: product != nil)

        if let product = product {
            trackEvent(TrackerEvent.productSellConfirmationClose(product, user: user))
        } else if let error = postProductError {
            trackEvent(TrackerEvent.productSellErrorClose(user, error: error))
        }
    }

    func editActionPressed() {
        guard let product = product else { return }
        trackEvent(TrackerEvent.productSellConfirmationEdit(product, user: user))
        delegate?.productPostedViewModelDidEditPosting(self, editViewModel: EditSellProductViewModel(product: product))
    }

    func mainActionPressed() {
        delegate?.productPostedViewModelDidRestartPosting(self)

        if let product = product {
            trackEvent(TrackerEvent.productSellConfirmationPost(product, user: user))
        } else if let error = postProductError {
            trackEvent(TrackerEvent.productSellErrorPost(user, error: error))
        }
    }

    func shareInEmail(){
        guard let product = product else { return }

        trackEvent(TrackerEvent.productSellConfirmationShare(product, user: user, network: .Email))
    }

    func shareInTwitter() {
        guard let product = product else { return }
        trackEvent(TrackerEvent.productSellConfirmationShare(product, user: user, network: .Twitter))
    }

    func shareInFacebook() {
        guard let product = product else { return }
        trackEvent(TrackerEvent.productSellConfirmationShare(product, user: user, network: .Facebook))
    }

    func shareInFacebookFinished(state: SocialShareState) {
        guard let product = product else { return }
        switch state {
        case .Completed:
            trackEvent(TrackerEvent.productSellConfirmationShareComplete(product, user: user, network: .Facebook))
        case .Cancelled:
            trackEvent(TrackerEvent.productSellConfirmationShareCancel(product, user: user, network: .Facebook))
        case .Failed:
                break;
        }
    }

    func shareInFBMessenger() {
        guard let product = product else { return }
        trackEvent(TrackerEvent.productSellConfirmationShare(product, user: user, network: .FBMessenger))
    }

    func shareInFBMessengerFinished(state: SocialShareState) {
        guard let product = product else { return }
        switch state {
        case .Completed:
            trackEvent(TrackerEvent.productSellConfirmationShareComplete(product, user: user, network: .FBMessenger))
        case .Cancelled:
            trackEvent(TrackerEvent.productSellConfirmationShareCancel(product, user: user, network: .FBMessenger))
        case .Failed:
            break;
        }
    }

    func shareInWhatsApp() {
        guard let product = product else { return }
        trackEvent(TrackerEvent.productSellConfirmationShare(product, user: user, network: .Whatsapp))
    }
    

    // MARK: - Private methods

    private func setup(postResult: ProductSaveServiceResult) {
        if let product = postResult.value {
            self.product = product
            mainText = LGLocalizedString.productPostConfirmationTitle.uppercaseString
            secondaryText = LGLocalizedString.productPostConfirmationSubtitle
            mainButtonText = LGLocalizedString.productPostConfirmationAnotherButton
            shareInfo = SocialHelper.socialMessageWithTitle(LGLocalizedString.sellShareFbContent, product: product)
        }
        else {
            let error = postResult.error ?? .Internal
            switch error {
            case .Network:
                secondaryText = LGLocalizedString.productPostNetworkError
                postProductError = .Network
            default:
                secondaryText = LGLocalizedString.productPostGenericError
                postProductError = .Internal
            }
            mainText = LGLocalizedString.commonErrorTitle.capitalizedString
            mainButtonText = LGLocalizedString.productPostRetryButton
        }
    }

    private func trackEvent(event: TrackerEvent?) {
        guard let event = event else { return }
        TrackerProxy.sharedInstance.trackEvent(event)
    }
}