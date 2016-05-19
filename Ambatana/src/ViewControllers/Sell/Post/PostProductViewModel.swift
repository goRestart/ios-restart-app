//
//  PostProductViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 11/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

protocol PostProductViewModelDelegate: class {
    func postProductViewModelDidStartUploadingImage(viewModel: PostProductViewModel)
    func postProductViewModelDidFinishUploadingImage(viewModel: PostProductViewModel, error: String?)
    func postProductviewModelshouldClose(viewModel: PostProductViewModel, animated: Bool, completion: (() -> Void)?)
    func postProductviewModel(viewModel: PostProductViewModel, shouldAskLoginWithCompletion completion: () -> Void)
}


class PostProductViewModel: BaseViewModel {

    weak var delegate: PostProductViewModelDelegate?

    var usePhotoButtonText: String {
        if Core.sessionManager.loggedIn {
            return LGLocalizedString.productPostUsePhoto
        } else {
            return LGLocalizedString.productPostUsePhotoNotLogged
        }
    }
    var confirmationOkText: String {
        if Core.sessionManager.loggedIn {
            return LGLocalizedString.productPostProductPosted
        } else {
            return LGLocalizedString.productPostProductPostedNotLogged
        }
    }
    var currency: Currency? {
        guard let countryCode = locationManager.currentPostalAddress?.countryCode else { return nil }
        return currencyHelper.currencyWithCountryCode(countryCode)
    }

    private let productRepository: ProductRepository
    private let fileRepository: FileRepository
    private let myUserRepository: MyUserRepository
    private let commercializerRepository: CommercializerRepository
    private let locationManager: LocationManager
    private let currencyHelper: CurrencyHelper
    private var imageSelected: UIImage?
    private var pendingToUploadImage: UIImage?
    private var uploadedImage: File?
    private var uploadedImageSource: EventParameterPictureSource?


    // MARK: - Lifecycle

    override convenience init() {
        let productRepository = Core.productRepository
        let fileRepository = Core.fileRepository
        let myUserRepository = Core.myUserRepository
        let commercializerRepository = Core.commercializerRepository
        let locationManager = Core.locationManager
        let currencyHelper = Core.currencyHelper
        self.init(productRepository: productRepository, fileRepository: fileRepository,
            myUserRepository: myUserRepository, commercializerRepository: commercializerRepository,
            locationManager: locationManager, currencyHelper: currencyHelper)
    }

    init(productRepository: ProductRepository, fileRepository: FileRepository, myUserRepository: MyUserRepository,
         commercializerRepository: CommercializerRepository, locationManager: LocationManager, currencyHelper: CurrencyHelper) {
            self.productRepository = productRepository
            self.fileRepository = fileRepository
            self.myUserRepository = myUserRepository
            self.commercializerRepository = commercializerRepository
            self.locationManager = locationManager
            self.currencyHelper = currencyHelper
            super.init()
    }


    // MARK: - Public methods

    func onViewLoaded() {
        let myUser = myUserRepository.myUser
        let event = TrackerEvent.productSellStart(myUser)
        TrackerProxy.sharedInstance.trackEvent(event)
    }

    func retryButtonPressed() {
        guard let image = imageSelected, source = uploadedImageSource else { return }
        imageSelected(image, source: source)
    }

    func imageSelected(image: UIImage, source: EventParameterPictureSource) {
        uploadedImageSource = source
        imageSelected = image
        guard Core.sessionManager.loggedIn else {
            pendingToUploadImage = image
            self.delegate?.postProductViewModelDidFinishUploadingImage(self, error: nil)
            return
        }

        delegate?.postProductViewModelDidStartUploadingImage(self)

        fileRepository.upload(image, progress: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            guard let image = result.value else {
                guard let error = result.error else { return }
                let errorString: String
                switch (error) {
                case .Internal, .Unauthorized, .NotFound, .Forbidden:
                    errorString = LGLocalizedString.productPostGenericError
                case .Network:
                    errorString = LGLocalizedString.productPostNetworkError
                }
                strongSelf.delegate?.postProductViewModelDidFinishUploadingImage(strongSelf, error: errorString)
                return
            }
            strongSelf.uploadedImage = image

            strongSelf.delegate?.postProductViewModelDidFinishUploadingImage(strongSelf, error: nil)
        }
    }

    func shouldShowCloseAlert() -> Bool {
        return pendingToUploadImage != nil
    }

    func doneButtonPressed(priceText priceText: String?, sellController: SellProductViewController,
        delegate: SellProductViewControllerDelegate?) {
            let trackInfo = PostProductTrackingInfo(buttonName: .Done, imageSource: uploadedImageSource,
                price: priceText)
            if Core.sessionManager.loggedIn {
                self.delegate?.postProductviewModelshouldClose(self, animated: true, completion: { [weak self] in
                    guard let product = self?.buildProduct(priceText: priceText) else { return }
                    self?.saveProduct(product, showConfirmation: true, trackInfo: trackInfo, controller: sellController,
                        delegate: delegate)
                    })
            } else if let imageToUpload = pendingToUploadImage {
                forwardProductCreationToProductPostedViewController(imageToUpload: imageToUpload, priceText: priceText,
                    trackInfo: trackInfo, controller: sellController, sellDelegate: delegate)
            }
    }

    func closeButtonPressed(sellController sellController: SellProductViewController,
        delegate: SellProductViewControllerDelegate?) {
            guard let product = buildProduct(priceText: nil) else {
                self.delegate?.postProductviewModelshouldClose(self, animated: true, completion: nil)
                return
            }

            self.delegate?.postProductviewModelshouldClose(self, animated: true, completion: { [weak self] in
                let trackInfo = PostProductTrackingInfo(buttonName: .Close, imageSource: self?.uploadedImageSource,
                    price: nil)
                self?.saveProduct(product, showConfirmation: false, trackInfo: trackInfo, controller: sellController,
                    delegate: delegate)
                })
    }


    // MARK: - Private methods

    private func saveProduct(theProduct: Product, showConfirmation: Bool, trackInfo: PostProductTrackingInfo,
        controller: SellProductViewController, delegate: SellProductViewControllerDelegate?) {
            guard let uploadedImage = uploadedImage else { return }

            productRepository.create(theProduct, images: [uploadedImage]) { [weak self] result in
                // Tracking
                if let product = result.value {
                    let myUser = Core.myUserRepository.myUser
                    let event = TrackerEvent.productSellComplete(myUser, product: product, buttonName:
                        trackInfo.buttonName, negotiable: trackInfo.negotiablePrice,
                        pictureSource: trackInfo.imageSource)
                    TrackerProxy.sharedInstance.trackEvent(event)

                    // Track product was sold in the first 24h (and not tracked before)
                    if let firstOpenDate = KeyValueStorage.sharedInstance[.firstRunDate]
                        where NSDate().timeIntervalSinceDate(firstOpenDate) <= 86400 &&
                            !KeyValueStorage.sharedInstance.userTrackingProductSellComplete24hTracked {
                        KeyValueStorage.sharedInstance.userTrackingProductSellComplete24hTracked = true

                        let event = TrackerEvent.productSellComplete24h(product)
                        TrackerProxy.sharedInstance.trackEvent(event)
                    }
                }

                if showConfirmation {
                    let productPostedViewModel = ProductPostedViewModel(postResult: result, trackingInfo: trackInfo)
                    delegate?.sellProductViewController(controller, didFinishPostingProduct: productPostedViewModel)
                } else {
                    var promoteProductVM: PromoteProductViewModel? = nil
                    if let product = result.value, let countryCode = product.postalAddress.countryCode, let productId = product.objectId {
                        let themes = self?.commercializerRepository.templatesForCountryCode(countryCode) ?? []
                        promoteProductVM = PromoteProductViewModel(productId: productId, themes: themes, commercializers: [],
                                                                   promotionSource: .ProductSell)
                    }
                    delegate?.sellProductViewController(controller, didCompleteSell: result.value != nil,
                        withPromoteProductViewModel: promoteProductVM)
                }
            }
    }

    private func forwardProductCreationToProductPostedViewController(imageToUpload image: UIImage,
        priceText: String?, trackInfo: PostProductTrackingInfo, controller: SellProductViewController,
        sellDelegate: SellProductViewControllerDelegate?) {
            delegate?.postProductviewModel(self, shouldAskLoginWithCompletion: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.postProductviewModelshouldClose(strongSelf, animated: false, completion: {
                    [weak self] in
                    guard let product = self?.buildProduct(priceText: priceText) else { return }
                    let productPostedViewModel = ProductPostedViewModel(productToPost: product, productImage: image,
                        trackingInfo: trackInfo)
                    sellDelegate?.sellProductViewController(controller, didFinishPostingProduct: productPostedViewModel)
                    })
                })
    }

    private func buildProduct(priceText priceText: String?) -> Product? {
        let priceText = priceText ?? "0"
        let price = priceText.toPriceDouble()
        return productRepository.buildNewProduct(price: price)
    }
}
