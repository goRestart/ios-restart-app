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
}

class PostProductViewModel: BaseViewModel {

    weak var delegate: PostProductViewModelDelegate?

    private var productManager: ProductManager
    private var uploadedImage: File?
    private var uploadedImageSource: EventParameterPictureSource?
    var currency: Currency

    override init() {
        self.productManager = ProductManager()
        self.currency = CurrencyHelper.sharedInstance.currentCurrency

        super.init()
    }


     // MARK: - Public methods

    func onViewLoaded() {
        let myUser = MyUserManager.sharedInstance.myUser()
        let event = TrackerEvent.productSellStart(myUser)
        TrackerProxy.sharedInstance.trackEvent(event)
    }

    func pressedRetakeImage() {
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

        delegate?.postProductViewModelDidStartUploadingImage(self)

        productManager.saveProductImages([image], progress: nil) {
            [weak self] (multipleFilesUploadResult: MultipleFilesUploadServiceResult) -> Void in

            guard let strongSelf = self else { return }
            guard let images = multipleFilesUploadResult.value, let image = images.first else {
                let error = multipleFilesUploadResult.error ?? .Internal
                let errorString: String
                switch (error) {
                case .Internal:
                    errorString = LGLocalizedString.productPostGenericError
                case .Network:
                    errorString = LGLocalizedString.productPostNetworkError
                case .Forbidden:
                    errorString = LGLocalizedString.productPostGenericError
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
            let trackInfo = TrackingInfo(buttonName: .Done, imageSource: uploadedImageSource ?? .Camera,
                negotiablePrice: (price != nil && !price!.isEmpty) ? .No : .Yes)
            PostProductViewModel.saveProduct(manager: productManager, uploadedImage: uploadedImage, priceText: price,
                currency: currency, showConfirmation: true, trackInfo: trackInfo, controller: sellController,
                delegate: delegate)
    }

    func closeButtonPressed(sellController sellController: SellProductViewController,
        delegate: SellProductViewControllerDelegate?) {
            let imageSource = uploadedImageSource ?? .Camera
            let trackInfo = TrackingInfo(buttonName: .Close, imageSource: imageSource, negotiablePrice: .Yes)
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
            let formatter = NSNumberFormatter()
            formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
            formatter.usesGroupingSeparator = false
            var priceFloat : Float = 0
            if let priceText = priceText, let number = formatter.numberFromString(priceText) {
                priceFloat = number.floatValue
            }

            theProduct = productManager.updateProduct(theProduct, name: nil, price: priceFloat, description: nil,
                category: .Other, currency: currency)

            productManager.saveProduct(theProduct, imageFiles: [uploadedImage]){
                (r: ProductSaveServiceResult) -> Void in

                //Tracking
                if let product = r.value {
                    let myUser = MyUserManager.sharedInstance.myUser()
                    let event = TrackerEvent.productSellComplete(myUser, product: product, buttonName: trackInfo.buttonName,
                        negotiable: trackInfo.negotiablePrice, pictureSource: trackInfo.imageSource)
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
