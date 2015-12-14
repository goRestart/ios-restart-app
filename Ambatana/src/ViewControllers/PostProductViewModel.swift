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

    var currency: Currency

    private var productManager: ProductManager
    private var uploadedImage: File?

    override init() {
        self.productManager = ProductManager()
        self.currency = CurrencyHelper.sharedInstance.currentCurrency

        super.init()
    }


     // MARK: - Public methods

    func imageSelected(image: UIImage) {

        delegate?.postProductViewModelDidStartUploadingImage(self)

//        //TODO: JUST TO TEST
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
//            delegate?.postProductViewModelDidFinishUploadingImage(self, error: nil)
//        });


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

    func doneButtonPressed(priceText: String?, delegate: SellProductViewControllerDelegate?) {
        PostProductViewModel.saveProduct(manager: productManager, uploadedImage: uploadedImage, priceText: priceText,
            currency: currency, delegate: delegate)
    }

    func closeButtonPressed(delegate delegate: SellProductViewControllerDelegate?) {
        PostProductViewModel.saveProduct(manager: productManager, uploadedImage: uploadedImage, priceText: nil,
            currency: currency, delegate: delegate)
    }


    // MARK: - Private methods
    private static func saveProduct(manager productManager: ProductManager, uploadedImage: File?, priceText: String?,
        currency: Currency, delegate: SellProductViewControllerDelegate?) {
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

                let productPostedViewModel = ProductPostedViewModel(postResult: r)
                delegate?.sellProductViewController(nil, didFinishPostingProduct: productPostedViewModel)
            }
    }
}
