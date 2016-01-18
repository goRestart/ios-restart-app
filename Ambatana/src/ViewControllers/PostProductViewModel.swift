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

//        guard myUserRepository.loggedIn else {
//            pendingToUploadImage = image
//            self.delegate?.postProductViewModelDidFinishUploadingImage(self, error: nil)
//            return
//        }

        delegate?.postProductViewModelDidStartUploadingImage(self)

        fileRepository.upload(image, progress: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            guard let image = result.value else {
                let error = result.error ?? RepositoryError.Internal(message: "")
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

    func doneButtonPressed(priceText price: String?, sellController: SellProductViewController,
        delegate: SellProductViewControllerDelegate?) {
            if myUserRepository.loggedIn {
                let trackInfo = TrackingInfo(buttonName: .Done, imageSource: uploadedImageSource, price: price)
                PostProductViewModel.saveProduct(repository: productRepository, uploadedImage: uploadedImage, priceText: price,
                    currency: currency, showConfirmation: true, trackInfo: trackInfo, controller: sellController,
                    delegate: delegate)
            }
    }

    func closeButtonPressed(sellController sellController: SellProductViewController,
        delegate: SellProductViewControllerDelegate?) {
            guard myUserRepository.loggedIn else { return }

            let trackInfo = TrackingInfo(buttonName: .Close, imageSource: uploadedImageSource, price: nil)
            PostProductViewModel.saveProduct(repository: productRepository, uploadedImage: uploadedImage, priceText: nil,
                currency: currency, showConfirmation: false, trackInfo: trackInfo, controller: sellController,
                delegate: delegate)
    }


    // MARK: - Private methods
    
    private static func saveProduct(repository productRepository: ProductRepository, uploadedImage: File?, priceText: String?,
        currency: Currency, showConfirmation: Bool, trackInfo: TrackingInfo, controller: SellProductViewController,
        delegate: SellProductViewControllerDelegate?) {
            guard let uploadedImage = uploadedImage, var theProduct = productRepository.newProduct() else { return }

            let priceText = priceText ?? "0"
            theProduct = productRepository.updateProduct(theProduct, name: nil, price: priceText.toPriceDouble(),
                description: nil, category: .Other, currency: currency)

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
}
