//
//  EditSellProductViewModel.swift
//  LetGo
//
//  Created by Dídac on 23/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import SDWebImage
import LGCoreKit

protocol EditSellProductViewModelDelegate : class {
    func editSellProductViewModel(viewModel: EditSellProductViewModel, didDownloadImageAtIndex index: Int)
}

protocol UpdateDetailInfoDelegate : class {
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
            self.price = price.stringValue
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

        // Download the images
        let imageDownloadQueue = dispatch_queue_create("EditSellProductViewModel", DISPATCH_QUEUE_SERIAL)
        dispatch_async(imageDownloadQueue, { () -> Void in
            for (index, image) in enumerate(product.images) {
                if let imageURL = image.fileURL, let data = NSData(contentsOfURL: imageURL) {
                    // Replace de image & notify the delegate
                    self.images[index] = UIImage(data: data)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.editDelegate?.editSellProductViewModel(self, didDownloadImageAtIndex: index)
                    })
                }
            }
        })
    }
    
    // MARK: - Public methods
    
    public override func save() {
        super.saveProduct(product: product)
    }
    
    // MARK: - Tracking methods

    internal override func trackStart() {
        super.trackStart()
        let event : TrackingEvent = TrackingEvent.ProductEditStart
        TrackingHelper.trackEvent(event, parameters: trackingParamsForEventType(event))
    }
    
    internal override func trackAddedImage() {
        super.trackAddedImage()
        let event : TrackingEvent = TrackingEvent.ProductEditAddPicture
        TrackingHelper.trackEvent(event, parameters: trackingParamsForEventType(event))
    }

    public override func trackEditedTitle() {
        super.trackEditedTitle()
        let event : TrackingEvent = TrackingEvent.ProductEditEditTitle
        TrackingHelper.trackEvent(event, parameters: trackingParamsForEventType(event))
    }
    
    public override func trackEditedPrice() {
        super.trackEditedPrice()
        let event : TrackingEvent = TrackingEvent.ProductEditEditPrice
        TrackingHelper.trackEvent(event, parameters: trackingParamsForEventType(event))
    }
    
    public override func trackEditedDescription() {
        super.trackEditedDescription()
        let event : TrackingEvent = TrackingEvent.ProductEditEditDescription
        TrackingHelper.trackEvent(event, parameters: trackingParamsForEventType(event))
    }
    
    internal override func trackEditedCategory() {
        super.trackEditedCategory()
        let event : TrackingEvent = TrackingEvent.ProductEditEditCategory
        TrackingHelper.trackEvent(event, parameters: trackingParamsForEventType(event))
    }
    
    public override func trackEditedFBChanged() {
        super.trackEditedFBChanged()
        let event : TrackingEvent = TrackingEvent.ProductEditEditShareFB
        TrackingHelper.trackEvent(event, parameters: trackingParamsForEventType(event))
    }
    
    
    internal override func trackValidationFailedWithError(error: ProductSaveServiceError) {
        super.trackValidationFailedWithError(error)
        let event : TrackingEvent = TrackingEvent.ProductEditFormValidationFailed
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
            TrackingHelper.trackEvent(event, parameters: trackingParamsForEventType(event, value: actualMessage))
        }
    }
    
    public override func trackSharedFB() {
        super.trackSharedFB()
        let event : TrackingEvent = TrackingEvent.ProductEditSharedFB
        TrackingHelper.trackEvent(event, parameters: trackingParamsForEventType(event))
    }
    
    internal override func trackComplete() {
        super.trackComplete()
        let event : TrackingEvent = TrackingEvent.ProductEditComplete
        TrackingHelper.trackEvent(event, parameters: trackingParamsForEventType(event))
    }
    
    internal override func trackAbandon() {
        super.trackAbandon()
        let event : TrackingEvent = TrackingEvent.ProductEditAbandon
        TrackingHelper.trackEvent(event, parameters: trackingParamsForEventType(event))
    }
    
    // MARK: - Tracking Private methods
       
    private func trackingParamsForEventType(eventType: TrackingEvent, value: AnyObject? = nil) -> [TrackingParameter: AnyObject]? {
        var params: [TrackingParameter: AnyObject] = [:]
        
        // Common
        if let myUser = MyUserManager.sharedInstance.myUser() {
            if let userId = myUser.objectId {
                params[.UserId] = userId
            }
            if let userCity = myUser.postalAddress.city {
                params[.UserCity] = userCity
            }
            if let userCountry = myUser.postalAddress.countryCode {
                params[.UserCountry] = userCountry
            }
            if let userZipCode = myUser.postalAddress.zipCode {
                params[.UserZipCode] = userZipCode
            }
        }
        if let actualProductId = product.objectId {
            params[.ProductId] = actualProductId
        }
        
        // Non-common
        if eventType == .ProductEditAddPicture {
            params[.Number] = images.count
        }
        
        if eventType == .ProductEditSharedFB || eventType == .ProductEditComplete {
            params[.ProductName] = title ?? "none"
        }
        
        if eventType == .ProductEditFormValidationFailed {
            params[.Description] = value
        }
        
        if eventType == .ProductEditEditShareFB {
            params[.Enabled] = shouldShareInFB
        }
        
        if eventType == .ProductEditEditCategory || eventType == .ProductEditComplete {
            params[.CategoryId] = category?.rawValue ?? 0
        }
        
        if eventType == .ProductEditComplete {
            
        }
        
        return params
    }
    
    // MARK: - Update info of previous VC
    
    public func updateInfoOfPreviousVC() {
        updateDetailDelegate?.updateDetailInfo(self)
    }
}
