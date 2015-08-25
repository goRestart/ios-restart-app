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
    func updateDetailInfo(viewModel: EditSellProductViewModel)
}

public class EditSellProductViewModel: SellProductViewModel {
 
    private var product: Product
    weak var updateDetailDelegate : UpdateDetailInfoDelegate?
    
    public init(product: Product) {
        self.product = product
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
        if let categoryId = product.categoryId?.integerValue {
            category = ProductCategory(rawValue: categoryId)
        }
        for i in 0..<product.images.count {
            images.append(nil)
        }
    }
    
    // MARK: - Public methods
    
    public override func save() {
        super.saveProduct(product: product)
    }
    
    public func loadPictures() {
        // Download the images
        for (index, image) in enumerate(product.images) {
            if let imageURL = image.fileURL {
                let imageManager = SDWebImageManager.sharedManager()
                imageManager.downloadImageWithURL(imageURL, options: .allZeros, progress: nil) { [weak self] (image: UIImage!, _, _, _, _) -> Void in
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
        let event = TrackerEvent.productEditStart(myUser, product: product)
        trackEvent(event)
    }
    
    
    internal override func trackValidationFailedWithError(error: ProductSaveServiceError) {
        super.trackValidationFailedWithError(error)
        let message: String?
        switch error {
        case .NoImages:
            message = "no images present"
        case .NoTitle:
            message = "no title"
        case .NoPrice:
            message = "invalid price"
        case .NoDescription:
            message = "no description"
        case .LongDescription:
            message = "description too long"
        case .NoCategory:
            message = "no category selected"
        default:
            message = nil
        }
        
        if let actualMessage = message {
            let myUser = MyUserManager.sharedInstance.myUser()
            let event = TrackerEvent.productEditFormValidationFailed(myUser, product: product, description: actualMessage)
            trackEvent(event)
        }
    }
    
    public override func trackSharedFB() {
        super.trackSharedFB()
        let myUser = MyUserManager.sharedInstance.myUser()
        let event = TrackerEvent.productEditSharedFB(myUser, product: product)
        trackEvent(event)
    }
    
    internal override func trackComplete() {
        super.trackComplete()
        let myUser = MyUserManager.sharedInstance.myUser()
        let event = TrackerEvent.productEditComplete(myUser, product: product, category: category)
        trackEvent(event)
    }
    
    
    // MARK: - Tracking Private methods
    
    private func trackEvent(event: TrackerEvent) {
        if shouldTrack {
            TrackerProxy.sharedInstance.trackEvent(event)
        }
    }
    
    // MARK: - Update info of previous VC
    
    public func updateInfoOfPreviousVC() {
        updateDetailDelegate?.updateDetailInfo(self)
    }
}
