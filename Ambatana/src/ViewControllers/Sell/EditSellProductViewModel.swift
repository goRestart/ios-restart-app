//
//  EditSellProductViewModel.swift
//  LetGo
//
//  Created by Dídac on 23/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import SDWebImage
import LGCoreKit

public protocol EditSellProductViewModelDelegate : class {
    func editSellProductViewModel(viewModel: EditSellProductViewModel, didDownloadImageAtIndex index: Int)
}

public protocol UpdateDetailInfoDelegate : class {
    func updateDetailInfo(viewModel: EditSellProductViewModel,  withSavedProduct: Product)
}

public class EditSellProductViewModel: SellProductViewModel {

    private var editedProduct: Product
    weak var updateDetailDelegate : UpdateDetailInfoDelegate?

    private var initialProduct: Product
    //    private var editedFields: [EventParameterEditedFields]

    public init(product: Product) {

        self.editedProduct = product
        self.initialProduct = product
        super.init()

        if let name = product.name {
            self.title = name
        }
        if let currency = product.currency {
            self.currency = currency
        }
        if let price = product.price {
            let numFormatter = NSNumberFormatter()
            numFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
            numFormatter.usesGroupingSeparator = false
            self.price = numFormatter.stringFromNumber(price)!
        }
        if let descr = product.descr {
            self.descr = descr
        }
        category = product.category
        for _ in 0..<product.images.count {
            images.append(nil)
        }
    }


    // MARK: - Public methods

    public override func save() {
        super.saveProduct(editedProduct)
    }

    public func loadPictures() {
        // Download the images
        for (index, image) in (editedProduct.images).enumerate() {
            if let imageURL = image.fileURL {
                let imageManager = SDWebImageManager.sharedManager()
                imageManager.downloadImageWithURL(imageURL, options: [], progress: nil) {
                    [weak self] (image: UIImage!, _, _, _, _) -> Void in
                    if let strongSelf = self {
                        // Replace de image & notify the delegate
                        strongSelf.images[index] = image
                        strongSelf.editDelegate?.editSellProductViewModel(strongSelf, didDownloadImageAtIndex: index)
                    }
                }
            }
        }
    }


    // MARK: - Tracking methods

    internal override func trackStart() {
        super.trackStart()
        let myUser = MyUserManager.sharedInstance.myUser()
        let event = TrackerEvent.productEditStart(myUser, product: editedProduct)
        trackEvent(event)
    }


    internal override func trackValidationFailedWithError(error: ProductSaveServiceError) {
        super.trackValidationFailedWithError(error)

        let myUser = MyUserManager.sharedInstance.myUser()
        let event = TrackerEvent.productEditFormValidationFailed(myUser, product: editedProduct,
            description: error.rawValue)
        trackEvent(event)
    }

    internal override func trackSharedFB() {
        super.trackSharedFB()
        let myUser = MyUserManager.sharedInstance.myUser()
        let event = TrackerEvent.productEditSharedFB(myUser, product: savedProduct)
        trackEvent(event)
    }

    internal override func trackComplete(product: Product) {
        self.editedProduct = product

        super.trackComplete(product)

        // if nothing is changed, we don't track the edition
        guard editedFields().count > 0  else { return }

        let myUser = MyUserManager.sharedInstance.myUser()
        let event = TrackerEvent.productEditComplete(myUser, product: product, category: category,
            editedFields: editedFields())
        trackEvent(event)
    }


    // MARK: - Tracking Private methods

    private func trackEvent(event: TrackerEvent) {
        if shouldTrack {
            TrackerProxy.sharedInstance.trackEvent(event)
        }
    }

    private func editedFields() -> [EventParameterEditedFields] {

        var editedFields : [EventParameterEditedFields] = []

        if imagesChanged()  {
            editedFields.append(.Picture)
        }
        if initialProduct.name != editedProduct.name {
            editedFields.append(.Title)
        }
        if initialProduct.priceString() != editedProduct.priceString() {
            editedFields.append(.Price)
        }
        if initialProduct.descr != editedProduct.descr {
            editedFields.append(.Description)
        }
        if initialProduct.category != editedProduct.category {
            editedFields.append(.Category)
        }
        if shareInFbChanged() {
            editedFields.append(.Share)
        }

        return editedFields
    }

    private func imagesChanged() -> Bool {
        guard initialProduct.images.count != editedProduct.images.count else {
            var sameImages = true
            for initialImage in initialProduct.images {

                guard let fileURL = initialImage.fileURL, let urlsArray = editedProduct.images.map({$0.fileURL})
                    as? [NSURL] else {
                        return false
                }
                sameImages = sameImages && urlsArray.contains(fileURL)
            }
            return sameImages
        }
        return true
    }

    private func shareInFbChanged() -> Bool {
        return MyUserManager.sharedInstance.myUser()?.didLogInByFacebook != shouldShareInFB
    }


    // MARK: - Update info of previous VC

    public func updateInfoOfPreviousVCWithProduct(savedProduct: Product) {
        updateDetailDelegate?.updateDetailInfo(self, withSavedProduct: savedProduct)
    }
}
