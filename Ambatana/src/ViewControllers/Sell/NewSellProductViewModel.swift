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
        let event = TrackerEvent.productSellStart(myUserRepository.myUser)
        tracker.trackEvent(event)
    }
    
    
    internal override func trackValidationFailedWithError(error: ProductSaveServiceError) {
        super.trackValidationFailedWithError(error)
        let event = TrackerEvent.productSellFormValidationFailed(myUserRepository.myUser, description: error.rawValue)
        trackEvent(event)
    }
    
    internal override func trackSharedFB() {
        super.trackSharedFB()
        let event = TrackerEvent.productSellSharedFB(myUserRepository.myUser, product: savedProduct)
        trackEvent(event)
    }
    
    internal override func trackComplete(product: Product) {
        super.trackComplete(product)
        let event = TrackerEvent.productSellComplete(myUserRepository.myUser, product: product)
        trackEvent(event)
    }
    
    
    // MARK: - Tracking Private methods
    
    private func trackEvent(event: TrackerEvent) {
        if shouldTrack {
            tracker.trackEvent(event)
        }
    }
}
