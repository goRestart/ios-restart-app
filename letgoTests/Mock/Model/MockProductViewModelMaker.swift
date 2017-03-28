//
//  MockProductViewModelMaker.swift
//  LetGo
//
//  Created by Eli Kohen on 02/03/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import LGCoreKit


class MockProductViewModelMaker: ProductViewModelMaker {

    let myUserRepository: MockMyUserRepository
    let listingRepository: MockListingRepository
    let commercializerRepository: MockCommercializerRepository
    let chatWrapper: MockChatWrapper
    let locationManager: MockLocationManager
    let countryHelper: CountryHelper
    let featureFlags: MockFeatureFlags
    let purchasesShopper: MockPurchasesShopper
    let monetizationRepository: MockMonetizationRepository
    let tracker: MockTracker

    init(myUserRepository: MockMyUserRepository,
         listingRepository: MockListingRepository,
         commercializerRepository: MockCommercializerRepository,
         chatWrapper: MockChatWrapper,
         locationManager: MockLocationManager,
         countryHelper: CountryHelper,
         featureFlags: MockFeatureFlags,
         purchasesShopper: MockPurchasesShopper,
         monetizationRepository: MockMonetizationRepository,
         tracker: MockTracker) {
        self.myUserRepository = myUserRepository
        self.listingRepository = listingRepository
        self.commercializerRepository = commercializerRepository
        self.chatWrapper = chatWrapper
        self.locationManager = locationManager
        self.countryHelper = countryHelper
        self.featureFlags = featureFlags
        self.purchasesShopper = purchasesShopper
        self.monetizationRepository = monetizationRepository
        self.tracker = tracker
    }

    func make(product: Product) -> ProductViewModel {
        return ProductViewModel(product: product,
                                myUserRepository: myUserRepository,
                                listingRepository: listingRepository,
                                commercializerRepository: commercializerRepository,
                                chatWrapper: chatWrapper,
                                chatViewMessageAdapter: ChatViewMessageAdapter(),
                                locationManager: locationManager,
                                countryHelper: countryHelper,
                                socialSharer: SocialSharer(),
                                featureFlags: featureFlags,
                                purchasesShopper: purchasesShopper,
                                monetizationRepository: monetizationRepository,
                                tracker: tracker)
    }
}
