//
//  ProductPostedViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 14/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

protocol ProductPostedViewModelDelegate: class {
    func productPostedViewModelSetupLoadingState(viewModel: ProductPostedViewModel)
    func productPostedViewModel(viewModel: ProductPostedViewModel, finishedLoadingState correct: Bool)
    func productPostedViewModel(viewModel: ProductPostedViewModel, setupStaticState correct: Bool)
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
    private var delayedPosting: Bool
    //Pendig post vars
    private var productRepository: ProductRepository?
    private var pendingProduct: Product?
    private var pendingImage: UIImage?

    //After posting vars
    private let myUserRepository: MyUserRepository
    private var product: Product?
    private var postProductError: EventParameterPostProductError?

    private var user: MyUser? {
        return Core.myUserRepository.myUser
    }
    
    
    // MARK: - Lifecycle

    convenience init(postResult: ProductResult) {
        let myUserRepository = Core.myUserRepository
        self.init(myUserRepository: myUserRepository, postResult: postResult)
    }

    init(myUserRepository: MyUserRepository, postResult: ProductResult) {
        self.delayedPosting = false
        self.myUserRepository = myUserRepository
        super.init()
        self.setup(postResult)
    }

    convenience init(productToPost: Product, productImage: UIImage) {
        let productRepository = Core.productRepository
        let myUserRepository = Core.myUserRepository
        self.init(myUserRepository:myUserRepository, productRepository: productRepository, productToPost: productToPost,
            productImage: productImage)
    }

    init(myUserRepository: MyUserRepository, productRepository: ProductRepository, productToPost: Product,
        productImage: UIImage) {
            self.delayedPosting = true
            self.myUserRepository = myUserRepository
            self.productRepository = productRepository
            self.pendingImage = productImage
            self.pendingProduct = productToPost
            super.init()
    }


    // MARK: - Public methods

    func onViewLoaded() {
        if let product = product {
            trackEvent(TrackerEvent.productSellConfirmation(product, user: user))
        } else if let error = postProductError {
            trackEvent(TrackerEvent.productSellError(user, error: error))
        }
    }

    override func didSetActive(active: Bool) {
        if active {
            if delayedPosting {
                postProduct()
            } else {
                delegate?.productPostedViewModel(self, setupStaticState: success)
            }
        }
    }

    func closeActionPressed() {
        delegate?.productPostedViewModelDidFinishPosting(self, correctly: success)

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

    private func setup(postResult: ProductResult) {
        if let product = postResult.value {
            self.product = product
            mainText = LGLocalizedString.productPostConfirmationTitle
            secondaryText = LGLocalizedString.productPostConfirmationSubtitle
            mainButtonText = LGLocalizedString.productPostConfirmationAnotherButton
            shareInfo = SocialHelper.socialMessageWithTitle(LGLocalizedString.sellShareFbContent, product: product)
        }
        else if let error = postResult.error {
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

    private func postProduct() {
        guard let productRepository = productRepository, product = pendingProduct, image = pendingImage else { return }

        delegate?.productPostedViewModelSetupLoadingState(self)

        productRepository.create(product, images: [image], progress: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.setup(result)
            strongSelf.delegate?.productPostedViewModel(strongSelf, finishedLoadingState: strongSelf.success)
        }
    }

    private func trackEvent(event: TrackerEvent?) {
        guard let event = event else { return }
        TrackerProxy.sharedInstance.trackEvent(event)
    }
}