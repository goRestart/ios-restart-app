//
//  NewSellProductViewModel.swift
//  LetGo
//
//  Created by Dídac on 16/09/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import SDWebImage
import LGCoreKit

public class NewSellProductViewModel: BaseSellProductViewModel {
   
    
    // MARK: - Tracking methods
    
    internal override func trackStart() {
        super.trackStart()
        let myUser = MyUserManager.sharedInstance.myUser()
        let event = TrackerEvent.productSellStart(myUser)
        TrackerProxy.sharedInstance.trackEvent(event)
    }
    
    
    internal override func trackValidationFailedWithError(error: ProductSaveServiceError) {
        super.trackValidationFailedWithError(error)

        let myUser = MyUserManager.sharedInstance.myUser()
        let event = TrackerEvent.productSellFormValidationFailed(myUser, description: error.rawValue)
        trackEvent(event)
    }
    
    internal override func trackSharedFB() {
        super.trackSharedFB()
        let myUser = MyUserManager.sharedInstance.myUser()
        let event = TrackerEvent.productSellSharedFB(myUser, product: savedProduct)
        trackEvent(event)
    }
    
    internal override func trackComplete(product: Product) {
        super.trackComplete(product)
        let myUser = MyUserManager.sharedInstance.myUser()
        let event = TrackerEvent.productSellComplete(myUser, product: product)
        trackEvent(event)
    }
    
    
    // MARK: - Tracking Private methods
    
    private func trackEvent(event: TrackerEvent) {
        if shouldTrack {
            TrackerProxy.sharedInstance.trackEvent(event)
        }
    }
}
