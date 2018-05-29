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
    let userRepository: MockUserRepository
    let listingRepository: MockListingRepository
    let chatWrapper: MockChatWrapper
    let locationManager: MockLocationManager
    let countryHelper: CountryHelper
    let featureFlags: MockFeatureFlags
    let purchasesShopper: MockPurchasesShopper
    let monetizationRepository: MockMonetizationRepository
    let tracker: MockTracker
    let keyValueStorage: MockKeyValueStorage
    let reputationTooltipManager: MockReputationTooltipManager

    init(myUserRepository: MockMyUserRepository,
         userRepository: MockUserRepository,
         listingRepository: MockListingRepository,
         chatWrapper: MockChatWrapper,
         locationManager: MockLocationManager,
         countryHelper: CountryHelper,
         featureFlags: MockFeatureFlags,
         purchasesShopper: MockPurchasesShopper,
         monetizationRepository: MockMonetizationRepository,
         tracker: MockTracker,
         keyValueStorage: MockKeyValueStorage,
         reputationTooltipManager: MockReputationTooltipManager) {
        self.myUserRepository = myUserRepository
        self.userRepository = userRepository
        self.listingRepository = listingRepository
        self.chatWrapper = chatWrapper
        self.locationManager = locationManager
        self.countryHelper = countryHelper
        self.featureFlags = featureFlags
        self.purchasesShopper = purchasesShopper
        self.monetizationRepository = monetizationRepository
        self.tracker = tracker
        self.keyValueStorage = keyValueStorage
        self.reputationTooltipManager = reputationTooltipManager
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
                                userRepository: userRepository,
                                listingRepository: listingRepository,
                                chatWrapper: chatWrapper,
                                chatViewMessageAdapter: ChatViewMessageAdapter(),
                                locationManager: locationManager,
                                countryHelper: countryHelper,
                                socialSharer: SocialSharer(),
                                featureFlags: featureFlags,
                                purchasesShopper: purchasesShopper,
                                monetizationRepository: monetizationRepository,
                                tracker: tracker,
                                keyValueStorage: keyValueStorage,
                                reputationTooltipManager: reputationTooltipManager)
    }

    func makeListingDeckSnapshot(listingViewModel: ListingViewModel) -> ListingDeckSnapshotType {
        return makeListingDeckSnapshot(listing: listingViewModel.listing.value)
    }
    func makeListingDeckSnapshot(listing: Listing) -> ListingDeckSnapshotType {
        let isMine = listing.isMine(myUserRepository: myUserRepository)
        let status = ListingViewModelStatus(listing: listing,
                                            isMine: listing.isMine(myUserRepository: myUserRepository),
                                            featureFlags: featureFlags)
        let info = ListingVMProductInfo(listing: listing,
                                        isAutoTranslated: listing.isTitleAutoTranslated(countryHelper),
                                        distance: nil,
                                        freeModeAllowed: featureFlags.freePostingModeAllowed,
                                        postingFlowType: featureFlags.postingFlowType)
        let userInfo = ListingVMUserInfo(userListing: listing.user, myUser: myUserRepository.myUser, sellerBadge: .silver)
        return ListingDeckSnapshot(preview: listing.images.first?.fileURL,
                                   imageCount: listing.images.count,
                                   isFavoritable: isMine,
                                   isFavorite: Bool.makeRandom(),
                                   userInfo: userInfo,
                                   status: status,
                                   isFeatured: Bool.makeRandom(),
                                   productInfo: info,
                                   stats: nil,
                                   postedDate: nil,
                                   socialSharer: SocialSharer(),
                                   socialMessage: MockListingSocialMessage(),
                                   isMine: true)
    }
}

struct MockListingSocialMessage: SocialMessage {
    func retrieveShareURL(source: ShareSource?, completion: @escaping AppsFlyerGenerateInviteURLCompletion) { }

    static var utmCampaignValue: String = ""
    var myUserId: String?
    var myUserName: String?
    var emailShareSubject: String = ""
    var emailShareIsHtml: Bool = false
    var fallbackToStore: Bool = false
    var controlParameter: String = ""

    func retrieveNativeShareItems(completion: @escaping NativeShareItemsCompletion) { }
    func retrieveEmailShareBody(completion: @escaping MessageWithURLCompletion) { }
    func retrieveFullMessageWithURL(source: ShareSource, completion: @escaping MessageWithURLCompletion) { }
}
