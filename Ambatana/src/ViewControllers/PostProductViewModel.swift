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

    private var productManager: ProductManager
    private let myUserRepository: MyUserRepository
    private var pendingToUploadImage: UIImage?
    private var uploadedImage: File?
    private var uploadedImageSource: EventParameterPictureSource?
    var currency: Currency

    
    // MARK: - Lifecycle
    
    override convenience init() {
        let productManager = ProductManager()
        let currency = CurrencyHelper.sharedInstance.currentCurrency
        let myUserRepository = MyUserRepository.sharedInstance
        self.init(productManager: productManager, myUserRepository: myUserRepository, currency: currency)
    }

    init(productManager: ProductManager, myUserRepository: MyUserRepository, currency: Currency) {
        self.productManager = productManager
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

//        guard myUserRepository.loggedIn else {
//            pendingToUploadImage = image
//            self.delegate?.postProductViewModelDidFinishUploadingImage(self, error: nil)
//            return
//        }

        delegate?.postProductViewModelDidStartUploadingImage(self)

        productManager.saveProductImages([image], progress: nil) {
            [weak self] (multipleFilesUploadResult: MultipleFilesUploadServiceResult) -> Void in

            guard let strongSelf = self else { return }
            guard let images = multipleFilesUploadResult.value, let image = images.first else {
                let error = multipleFilesUploadResult.error ?? .Internal
                let errorString: String
                switch (error) {
                case .Internal, .Forbidden:
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

    func doneButtonPressed(priceText price: String?, sellController: SellProductViewController,
        delegate: SellProductViewControllerDelegate?) {
            if myUserRepository.loggedIn {
                let trackInfo = TrackingInfo(buttonName: .Done, imageSource: uploadedImageSource, price: price)
                PostProductViewModel.saveProduct(manager: productManager, uploadedImage: uploadedImage, priceText: price,
                    currency: currency, showConfirmation: true, trackInfo: trackInfo, controller: sellController,
                    delegate: delegate)
            } else {

            }
    }

    func closeButtonPressed(sellController sellController: SellProductViewController,
        delegate: SellProductViewControllerDelegate?) {
            guard myUserRepository.loggedIn else { return }

            let trackInfo = TrackingInfo(buttonName: .Close, imageSource: uploadedImageSource, price: nil)
            PostProductViewModel.saveProduct(manager: productManager, uploadedImage: uploadedImage, priceText: nil,
                currency: currency, showConfirmation: false, trackInfo: trackInfo, controller: sellController,
                delegate: delegate)
    }


    // MARK: - Private methods
    
    private static func saveProduct(manager productManager: ProductManager, uploadedImage: File?, priceText: String?,
        currency: Currency, showConfirmation: Bool, trackInfo: TrackingInfo, controller: SellProductViewController,
        delegate: SellProductViewControllerDelegate?) {
            guard let uploadedImage = uploadedImage else { return }

            var theProduct = productManager.newProduct()
            let priceText = priceText ?? "0"
            theProduct = productManager.updateProduct(theProduct, name: nil, price: priceText.toPriceDouble(),
                description: nil, category: .Other, currency: currency)

            productManager.saveProduct(theProduct, imageFiles: [uploadedImage]){
                (r: ProductSaveServiceResult) -> Void in

                //Tracking
                if let product = r.value {
                    let myUser = MyUserRepository.sharedInstance.myUser
                    let event = TrackerEvent.productSellComplete(myUser, product: product, buttonName:
                        trackInfo.buttonName, negotiable: trackInfo.negotiablePrice,
                        pictureSource: trackInfo.imageSource)
                    TrackerProxy.sharedInstance.trackEvent(event)
                }

                if showConfirmation {
                    let productPostedViewModel = ProductPostedViewModel(postResult: r)
                    delegate?.sellProductViewController(controller, didFinishPostingProduct: productPostedViewModel)
                } else {
                    delegate?.sellProductViewController(controller, didCompleteSell: r.value != nil)
                }
            }
    }
}
