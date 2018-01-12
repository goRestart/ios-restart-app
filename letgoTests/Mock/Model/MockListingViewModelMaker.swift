//
//  MockListingViewModelMaker.swift
//  LetGo
//
//  Created by Eli Kohen on 02/03/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import LGCoreKit


class MockListingViewModelMaker: ListingViewModelMaker {

    let myUserRepository: MockMyUserRepository
    let listingRepository: MockListingRepository
    let chatWrapper: MockChatWrapper
    let locationManager: MockLocationManager
    let countryHelper: CountryHelper
    let featureFlags: MockFeatureFlags
    let purchasesShopper: MockPurchasesShopper
    let monetizationRepository: MockMonetizationRepository
    let tracker: MockTracker

    init(myUserRepository: MockMyUserRepository,
         listingRepository: MockListingRepository,
         chatWrapper: MockChatWrapper,
         locationManager: MockLocationManager,
         countryHelper: CountryHelper,
         featureFlags: MockFeatureFlags,
         purchasesShopper: MockPurchasesShopper,
         monetizationRepository: MockMonetizationRepository,
         tracker: MockTracker) {
        self.myUserRepository = myUserRepository
        self.listingRepository = listingRepository
        self.chatWrapper = chatWrapper
        self.locationManager = locationManager
        self.countryHelper = countryHelper
        self.featureFlags = featureFlags
        self.purchasesShopper = purchasesShopper
        self.monetizationRepository = monetizationRepository
        self.tracker = tracker
    }

    func make(listing: Listing, navigator: ListingDetailNavigator?, visitSource: EventParameterListingVisitSource) -> ListingViewModel {
        let viewModel = make(listing: listing, visitSource: visitSource)
        viewModel.navigator = navigator
        return viewModel
    }

    func make(listing: Listing, visitSource: EventParameterListingVisitSource) -> ListingViewModel {
        return ListingViewModel(listing: listing,
                                visitSource: visitSource,
                                myUserRepository: myUserRepository,
                                listingRepository: listingRepository,
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
