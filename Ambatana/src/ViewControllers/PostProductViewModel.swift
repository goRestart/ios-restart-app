//
//  PostProductViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 11/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

protocol PostProductViewModelDelegate: class {
    func postProductViewModelDidRestartTakingImage(viewModel: PostProductViewModel)
    func postProductViewModel(viewModel: PostProductViewModel, didSelectImage image: UIImage)
    func postProductViewModelDidStartUploadingImage(viewModel: PostProductViewModel)
    func postProductViewModelDidFinishUploadingImage(viewModel: PostProductViewModel, error: String?)
    func postProductviewModel(viewModel: PostProductViewModel, shouldCloseWithCompletion completion: (() -> Void)?)
    func postProductviewModel(viewModel: PostProductViewModel, shouldAskLoginWithCompletion completion: () -> Void)
}

private struct TrackingInfo {
    var buttonName: EventParameterButtonNameType
    var imageSource: EventParameterPictureSource
    var negotiablePrice: EventParameterNegotiablePrice

    init(buttonName: EventParameterButtonNameType, imageSource: EventParameterPictureSource?, price: String?) {
        self.buttonName = buttonName
        self.imageSource = imageSource ?? .Camera
        if let price = price, let doublePrice = Double(price) {
            negotiablePrice = doublePrice > 0 ? .No : .Yes
        } else {
            negotiablePrice = .Yes
        }
    }
}

class PostProductViewModel: BaseViewModel {

    weak var delegate: PostProductViewModelDelegate?

    var usePhotoButtonText: String {
        if myUserRepository.loggedIn {
            return LGLocalizedString.productPostUsePhoto
        } else {
            return LGLocalizedString.productPostUsePhotoNotLogged
        }
    }
    var confirmationOkText: String {
        if myUserRepository.loggedIn {
            return LGLocalizedString.productPostProductPosted
        } else {
            return LGLocalizedString.productPostProductPostedNotLogged
        }
    }

    private let productRepository: ProductRepository
    private let fileRepository: FileRepository
    private let myUserRepository: MyUserRepository
    private var pendingToUploadImage: UIImage?
    private var uploadedImage: File?
    private var uploadedImageSource: EventParameterPictureSource?
    var currency: Currency

    
    // MARK: - Lifecycle
    
    override convenience init() {
        self.init(productRepository: ProductRepository.sharedInstance,
            fileRepository: LGFileRepository.sharedInstance,
            myUserRepository:  MyUserRepository.sharedInstance,
            currency: CurrencyHelper.sharedInstance.currentCurrency)
    }

    init(productRepository: ProductRepository, fileRepository: FileRepository, myUserRepository: MyUserRepository,
        currency: Currency) {
            self.productRepository = productRepository
            self.fileRepository = fileRepository
            self.myUserRepository = myUserRepository
            self.currency = currency
            super.init()
    }
    

    // MARK: - Public methods

    func onViewLoaded() {
        let myUser = myUserRepository.myUser
        let event = TrackerEvent.productSellStart(myUser)
        TrackerProxy.sharedInstance.trackEvent(event)
    }

    func pressedRetakeImage() {
        pendingToUploadImage = nil
        uploadedImage = nil
        uploadedImageSource = nil
        delegate?.postProductViewModelDidRestartTakingImage(self)
    }

    func takenImageFromCamera(image: UIImage) {
        uploadedImageSource = .Camera
        delegate?.postProductViewModel(self, didSelectImage: image)
    }

    func takenImageFromGallery(image: UIImage) {
        uploadedImageSource = .Gallery
        delegate?.postProductViewModel(self, didSelectImage: image)
    }

    func imageSelected(image: UIImage) {

        guard myUserRepository.loggedIn else {
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
                case .Internal, .Unauthorized, .NotFound:
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
        return !myUserRepository.loggedIn
    }

    func doneButtonPressed(priceText priceText: String?, sellController: SellProductViewController,
        delegate: SellProductViewControllerDelegate?) {
            let trackInfo = TrackingInfo(buttonName: .Done, imageSource: uploadedImageSource, price: priceText)
            if myUserRepository.loggedIn {
                self.delegate?.postProductviewModel(self, shouldCloseWithCompletion: { [weak self] in
                    guard let product = self?.buildProduct(priceText: priceText) else { return }
                    self?.saveProduct(product, showConfirmation: true, trackInfo: trackInfo, controller: sellController,
                        delegate: delegate)
                    })
            } else if let imageToUpload = pendingToUploadImage {
                passInfoToConfirmation(imageToUpload: imageToUpload, priceText: priceText, trackInfo: trackInfo,
                    controller: sellController, sellDelegate: delegate)
            }
    }

    func closeButtonPressed(sellController sellController: SellProductViewController,
        delegate: SellProductViewControllerDelegate?) {
            guard let product = buildProduct(priceText: nil) else {
                self.delegate?.postProductviewModel(self, shouldCloseWithCompletion: nil)
                return
            }

            self.delegate?.postProductviewModel(self, shouldCloseWithCompletion: { [weak self] in
                let trackInfo = TrackingInfo(buttonName: .Close, imageSource: self?.uploadedImageSource, price: nil)
                self?.saveProduct(product, showConfirmation: false, trackInfo: trackInfo, controller: sellController,
                    delegate: delegate)
            })
    }


    // MARK: - Private methods
    
    private func saveProduct(theProduct: Product, showConfirmation: Bool, trackInfo: TrackingInfo,
        controller: SellProductViewController, delegate: SellProductViewControllerDelegate?) {
            guard let uploadedImage = uploadedImage else { return }

            productRepository.create(theProduct, images: [uploadedImage]) { result in
                //Tracking
                if let product = result.value {
                    let myUser = MyUserRepository.sharedInstance.myUser
                    let event = TrackerEvent.productSellComplete(myUser, product: product, buttonName:
                        trackInfo.buttonName, negotiable: trackInfo.negotiablePrice,
                        pictureSource: trackInfo.imageSource)
                    TrackerProxy.sharedInstance.trackEvent(event)
                }

                if showConfirmation {
                    let productPostedViewModel = ProductPostedViewModel(postResult: result)
                    delegate?.sellProductViewController(controller, didFinishPostingProduct: productPostedViewModel)
                } else {
                    delegate?.sellProductViewController(controller, didCompleteSell: result.value != nil)
                }
            }
    }

    private func passInfoToConfirmation(imageToUpload image: UIImage, priceText: String?, trackInfo: TrackingInfo,
        controller: SellProductViewController, sellDelegate: SellProductViewControllerDelegate?) {
            delegate?.postProductviewModel(self, shouldAskLoginWithCompletion: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.postProductviewModel(strongSelf, shouldCloseWithCompletion: { [weak self] in
                    guard let product = self?.buildProduct(priceText: priceText) else { return }
                    let productPostedViewModel = ProductPostedViewModel(productToPost: product, productImage: image)
                    sellDelegate?.sellProductViewController(controller, didFinishPostingProduct: productPostedViewModel)
                })
            })
    }

    private func buildProduct(priceText priceText: String?) -> Product? {
        guard let theProduct = productRepository.newProduct() else { return nil }
        let priceText = priceText ?? "0"
        let price = priceText.toPriceDouble()
        return productRepository.updateProduct(theProduct, name: nil, price: price, description: nil,
            category: .Other, currency: currency)
    }
}
