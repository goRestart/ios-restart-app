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
}

class PostProductViewModel: BaseViewModel {

    weak var delegate: PostProductViewModelDelegate?

    private var productManager: ProductManager
    private var uploadedImage: File?
    var currency: Currency

    override init() {
        self.productManager = ProductManager()
        self.currency = CurrencyHelper.sharedInstance.currentCurrency

        super.init()
    }


     // MARK: - Public methods

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

    func doneButtonPressed(priceText priceText: String?, sellController: SellProductViewController,
        delegate: SellProductViewControllerDelegate?) {
        PostProductViewModel.saveProduct(manager: productManager, uploadedImage: uploadedImage, priceText: priceText,
            currency: currency, showConfirmation: true, controller: sellController, delegate: delegate)
    }

    func closeButtonPressed(sellController sellController: SellProductViewController,
        delegate: SellProductViewControllerDelegate?) {
        PostProductViewModel.saveProduct(manager: productManager, uploadedImage: uploadedImage, priceText: nil,
            currency: currency, showConfirmation: false, controller: sellController, delegate: delegate)
    }


    // MARK: - Private methods
    private static func saveProduct(manager productManager: ProductManager, uploadedImage: File?, priceText: String?,
        currency: Currency, showConfirmation: Bool, controller: SellProductViewController,
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

                if showConfirmation {
                    let productPostedViewModel = ProductPostedViewModel(postResult: r)
                    delegate?.sellProductViewController(controller, didFinishPostingProduct: productPostedViewModel)
                } else {
                    delegate?.sellProductViewController(controller, didCompleteSell: r.value != nil)
                }
            }
    }
}
