//
//  ProductPostedViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 14/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit


// MARK: - ProductPostedViewModelDelegate

protocol ProductPostedViewModelDelegate: class {
    func productPostedViewModelSetupLoadingState(viewModel: ProductPostedViewModel)
    func productPostedViewModel(viewModel: ProductPostedViewModel, finishedLoadingState correct: Bool)
    func productPostedViewModel(viewModel: ProductPostedViewModel, setupStaticState correct: Bool)
    func productPostedViewModelDidFinishPosting(viewModel: ProductPostedViewModel, correctly: Bool)
    func productPostedViewModelDidEditPosting(viewModel: ProductPostedViewModel,
        editViewModel: EditSellProductViewModel)
    func productPostedViewModelDidRestartPosting(viewModel: ProductPostedViewModel)
}


// MARK: - ProductPostedViewModel

class ProductPostedViewModel: BaseViewModel {

    weak var delegate: ProductPostedViewModelDelegate?

    private var status: ProductPostedStatus
    private var productRepository: ProductRepository?
    private let myUserRepository: MyUserRepository
    private var trackingInfo: PostProductTrackingInfo

    private var user: MyUser? {
        return Core.myUserRepository.myUser
    }
    private var activeFirstTime: Bool = true


    // MARK: - Lifecycle

    convenience init(postResult: ProductResult, trackingInfo: PostProductTrackingInfo) {
        let myUserRepository = Core.myUserRepository
        self.init(myUserRepository: myUserRepository, postResult: postResult, trackingInfo: trackingInfo)
    }

    init(myUserRepository: MyUserRepository, postResult: ProductResult, trackingInfo: PostProductTrackingInfo) {
        self.myUserRepository = myUserRepository
        self.trackingInfo = trackingInfo
        self.status = ProductPostedStatus(result: postResult)
        super.init()
    }

    convenience init(productToPost: Product, productImage: UIImage, trackingInfo: PostProductTrackingInfo) {
        let productRepository = Core.productRepository
        let myUserRepository = Core.myUserRepository
        self.init(myUserRepository:myUserRepository, productRepository: productRepository, productToPost: productToPost,
            productImage: productImage, trackingInfo: trackingInfo)
    }

    init(myUserRepository: MyUserRepository, productRepository: ProductRepository, productToPost: Product,
        productImage: UIImage, trackingInfo: PostProductTrackingInfo) {
            self.myUserRepository = myUserRepository
            self.productRepository = productRepository
            self.trackingInfo = trackingInfo
            self.status = ProductPostedStatus(image: productImage, product: productToPost)
            super.init()
    }

    override func didSetActive(active: Bool) {
        if active && activeFirstTime {
            activeFirstTime = false

            switch status {
            case let .Posting(image, product):
                postProduct(image, product: product)
            case .Success:
                delegate?.productPostedViewModel(self, setupStaticState: true)
                trackProductUploadResultScreen()
            case .Error:
                delegate?.productPostedViewModel(self, setupStaticState: false)
                trackProductUploadResultScreen()
            }
        }
    }


    // MARK: - Public

    var mainButtonText: String? {
        switch status {
        case .Posting:
            return nil
        case .Success:
            return LGLocalizedString.productPostConfirmationAnotherButton
        case .Error:
            return LGLocalizedString.productPostRetryButton
        }
    }

    var mainText: String? {
        switch status {
        case .Posting:
            return nil
        case .Success:
            return LGLocalizedString.productPostConfirmationTitle
        case .Error:
            return LGLocalizedString.commonErrorTitle.capitalizedString
        }
    }

    var secondaryText: String? {
        switch status {
        case .Posting:
            return nil
        case .Success:
            return LGLocalizedString.productPostConfirmationSubtitle
        case let .Error(error):
            switch error {
            case .Network:
                return LGLocalizedString.productPostNetworkError
            default:
                return LGLocalizedString.productPostGenericError
            }
        }
    }

    var shareInfo: SocialMessage? {
        switch status {
        case .Posting, .Error:
            return nil
        case let .Success(product):
            return SocialHelper.socialMessageWithTitle(LGLocalizedString.sellShareFbContent, product: product)
        }
    }

    var promoteProductViewModel: PromoteProductViewModel? {
        switch status {
        case .Posting, .Error:
            return nil
        case let .Success(product):
            guard let countryCode = product.postalAddress.countryCode else { return nil }
            guard let _ = Core.commercializerRepository.templatesForCountryCode(countryCode) else { return nil }
            return PromoteProductViewModel(product: product, promotionSource: .ProductSell)
        }
    }

    // MARK: > Actions

    func closeActionPressed() {
        switch status {
        case .Posting:
            break
        case let .Success(product):
            trackEvent(TrackerEvent.productSellConfirmationClose(product, user: user))
        case let .Error(error):
            trackEvent(TrackerEvent.productSellErrorClose(user, error: error))
        }
        delegate?.productPostedViewModelDidFinishPosting(self, correctly: status.success)
    }

    func editActionPressed() {
        guard let product = status.product else { return }

        trackEvent(TrackerEvent.productSellConfirmationEdit(product, user: user))

        let editViewModel = EditSellProductViewModel(product: product)
        delegate?.productPostedViewModelDidEditPosting(self, editViewModel: editViewModel)
    }

    func mainActionPressed() {
        delegate?.productPostedViewModelDidRestartPosting(self)

        switch status {
        case .Posting:
            break
        case let .Success(product):
            trackEvent(TrackerEvent.productSellConfirmationPost(product, user: user))
        case let .Error(error):
            trackEvent(TrackerEvent.productSellErrorPost(user, error: error))
        }
    }

    func shareInEmail() {
        guard let product = status.product else { return }
        trackEvent(TrackerEvent.productSellConfirmationShare(product, user: user, network: .Email))
    }

    func shareInTwitter() {
        guard let product = status.product else { return }
        trackEvent(TrackerEvent.productSellConfirmationShare(product, user: user, network: .Twitter))
    }

    func shareInFacebook() {
        guard let product = status.product else { return }
        trackEvent(TrackerEvent.productSellConfirmationShare(product, user: user, network: .Facebook))
    }

    func shareInFacebookFinished(state: SocialShareState) {
        guard let product = status.product else { return }
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
        guard let product = status.product else { return }
        trackEvent(TrackerEvent.productSellConfirmationShare(product, user: user, network: .FBMessenger))
    }

    func shareInFBMessengerFinished(state: SocialShareState) {
        guard let product = status.product else { return }
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
        guard let product = status.product else { return }
        trackEvent(TrackerEvent.productSellConfirmationShare(product, user: user, network: .Whatsapp))
    }
    

    // MARK: - Private methods

    private func postProduct(image: UIImage, product: Product) {
        guard let productRepository = productRepository else { return }

        delegate?.productPostedViewModelSetupLoadingState(self)

        productRepository.create(product, images: [image], progress: nil) { [weak self] result in
            guard let strongSelf = self else { return }

            // Tracking
            let myUser = strongSelf.myUserRepository.myUser
            if let postedProduct = result.value {
                let buttonName = strongSelf.trackingInfo.buttonName
                let negotiable = strongSelf.trackingInfo.negotiablePrice
                let pictureSource = strongSelf.trackingInfo.imageSource

                let event = TrackerEvent.productSellComplete(myUser, product: postedProduct,
                    buttonName: buttonName, negotiable: negotiable, pictureSource: pictureSource)
                strongSelf.trackEvent(event)
            }

            let status = ProductPostedStatus(result: result)
            strongSelf.status = status
            strongSelf.trackProductUploadResultScreen()
            strongSelf.delegate?.productPostedViewModel(strongSelf, finishedLoadingState: status.success)
        }
    }

    private func trackProductUploadResultScreen() {
        switch status {
        case .Posting:
            break
        case let .Success(product):
            trackEvent(TrackerEvent.productSellConfirmation(product, user: user))
        case let .Error(error):
            trackEvent(TrackerEvent.productSellError(user, error: error))
        }
    }

    private func trackEvent(event: TrackerEvent) {
        TrackerProxy.sharedInstance.trackEvent(event)
    }
}


// MARK: - ProductPostedStatus

private enum ProductPostedStatus {
    case Posting(image: UIImage, product: Product)
    case Success(product: Product)
    case Error(error: EventParameterPostProductError)

    var product: Product? {
        switch self {
        case .Posting, .Error:
            return nil
        case let .Success(product):
            return product
        }
    }

    var success: Bool {
        switch self {
        case .Success:
            return true
        case .Posting, .Error:
            return false
        }
    }

    init(image: UIImage, product: Product) {
        self = .Posting(image: image, product: product)
    }

    init(result: ProductResult) {
        if let product = result.value {
            self = .Success(product: product)
        } else if let error = result.error {
            switch error {
            case .Network:
                self = .Error(error: .Network)
            default:
                self = .Error(error: .Internal)
            }
        } else {
            self = .Error(error: .Internal)
        }
    }
}
