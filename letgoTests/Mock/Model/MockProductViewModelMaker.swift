//
//  MockProductViewModelMaker.swift
//  LetGo
//
//  Created by Eli Kohen on 02/03/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGo
import LGCoreKit


class MockProductViewModelMaker: ProductViewModelMaker {

    let myUserRepository: MockMyUserRepository
    let productRepository: MockProductRepository
    let commercializerRepository: MockCommercializerRepository
    let chatWrapper: MockChatWrapper
    let locationManager: MockLocationManager
    let countryHelper: CountryHelper
    let featureFlags: MockFeatureFlags
    let purchasesShopper: MockPurchasesShopper
    let notificationsManager: MockNotificationsManager
    let monetizationRepository: MockMonetizationRepository
    let tracker: MockTracker

    init(myUserRepository: MockMyUserRepository,
            productRepository: MockProductRepository,
            commercializerRepository: MockCommercializerRepository,
            chatWrapper: MockChatWrapper,
            locationManager: MockLocationManager,
            countryHelper: CountryHelper,
            featureFlags: MockFeatureFlags,
            purchasesShopper: MockPurchasesShopper,
            notificationsManager: MockNotificationsManager,
            monetizationRepository: MockMonetizationRepository,
            tracker: MockTracker) {
        self.myUserRepository = myUserRepository
        self.productRepository = productRepository
        self.commercializerRepository = commercializerRepository
        self.chatWrapper = chatWrapper
        self.locationManager = locationManager
        self.countryHelper = countryHelper
        self.featureFlags = featureFlags
        self.purchasesShopper = purchasesShopper
        self.notificationsManager = notificationsManager
        self.monetizationRepository = monetizationRepository
        self.tracker = tracker
    }

    func make(product: Product) -> ProductViewModel {
        return ProductViewModel(product: product,
                                myUserRepository: myUserRepository,
                                productRepository: productRepository,
                                commercializerRepository: commercializerRepository,
                                chatWrapper: chatWrapper,
                                chatViewMessageAdapter: ChatViewMessageAdapter(),
                                locationManager: locationManager,
                                countryHelper: countryHelper,
                                socialSharer: SocialSharer(),
                                featureFlags: featureFlags,
                                purchasesShopper: purchasesShopper,
                                notificationsManager: notificationsManager,
                                monetizationRepository: monetizationRepository,
                                tracker: tracker)
    }
}
