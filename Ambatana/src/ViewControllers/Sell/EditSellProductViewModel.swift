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
    
    public init(myUserRepository: MyUserRepository, productManager: ProductManager, tracker: Tracker, product: Product){
        self.editedProduct = product
        super.init(myUserRepository: myUserRepository, productManager: productManager, tracker: tracker)
        
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
    
    public convenience init(product: Product) {
        let myUserRepository = MyUserRepository.sharedInstance
        let productManager = ProductManager()
        let tracker = TrackerProxy.sharedInstance
        self.init(myUserRepository: myUserRepository, productManager: productManager, tracker: tracker,
            product: product)
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
                imageManager.downloadImageWithURL(imageURL, options: [], progress: nil) { [weak self] (image: UIImage!, _, _, _, _) -> Void in
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
        let myUser = myUserRepository.myUser
        let event = TrackerEvent.productEditStart(myUser, product: editedProduct)
        trackEvent(event)
    }
    
    
    internal override func trackValidationFailedWithError(error: ProductSaveServiceError) {
        super.trackValidationFailedWithError(error)

        let myUser = myUserRepository.myUser
        let event = TrackerEvent.productEditFormValidationFailed(myUser, product: editedProduct, description: error.rawValue)
        trackEvent(event)
    }
    
    internal override func trackSharedFB() {
        super.trackSharedFB()
        let myUser = myUserRepository.myUser
        let event = TrackerEvent.productEditSharedFB(myUser, product: savedProduct)
        trackEvent(event)
    }
    
    internal override func trackComplete(product: Product) {
        super.trackComplete(product)
        let myUser = myUserRepository.myUser
        let event = TrackerEvent.productEditComplete(myUser, product: product, category: category)
        trackEvent(event)
    }
    
    
    // MARK: - Tracking Private methods
    
    private func trackEvent(event: TrackerEvent) {
        if shouldTrack {
            tracker.trackEvent(event)
        }
    }
    
    // MARK: - Update info of previous VC
    
    public func updateInfoOfPreviousVCWithProduct(savedProduct: Product) {
        updateDetailDelegate?.updateDetailInfo(self, withSavedProduct: savedProduct)
    }
}
