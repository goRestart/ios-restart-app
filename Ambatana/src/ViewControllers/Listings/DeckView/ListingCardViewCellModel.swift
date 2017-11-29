//
//  ListingCardViewCellModel.swift
//  LetGo
//
//  Created by Facundo Menzella on 22/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import RxSwift

protocol ListingCardDetailsViewModel {
    var cardProductInfo: Observable<ListingVMProductInfo?> { get }
    var cardProductStats: Observable<ListingStats?> { get }
    var cardSocialSharer: SocialSharer { get }
    var cardSocialMessage: Observable<SocialMessage?> { get }
}

protocol ListingCardViewCellModel: ListingCardDetailsViewModel {
    var cardListing: Listing { get }
    var cardListingObs: Observable<Listing> { get }

    var cardStatus: Observable<ListingViewModelStatus> { get }
    var cardIsShowingFeaturedStripe: Observable<Bool> { get }
    var cardNavBarButtons: Observable<[UIAction]> { get }
    var cardActionButtons: Observable<[UIAction]> { get }
    var cardAltActions: Observable<[UIAction]> { get }

    var cardIsFavoritable: Bool { get }
    var cardIsFeatured: Observable<Bool> { get  }
    var productIsFavorite: Observable<Bool> { get }
    var cardUserInfo: Observable<ListingVMUserInfo> { get }
    var cardProductImageURLs: Observable<[URL]> { get }

    var cardQuickAnswers: [[QuickAnswer]] { get }
    var cardDirectChatEnabled: Observable<Bool> { get }
    var cardDirectChatMessages: Observable<CollectionChange<ChatViewMessage>> { get }
    var cardDirectChatPlaceholder: String { get }
    var cardBumpUpBannerInfo: Observable<BumpUpInfo?> { get }
}

extension ListingViewModel: ListingCardViewCellModel {

    // MARK: ListingCardDetailsViewModel
    var cardProductInfo: Observable<ListingVMProductInfo?> { return productInfo.asObservable() }
    var cardProductStats: Observable<ListingStats?> { return listingStats.asObservable() }
    var cardSocialSharer: SocialSharer { return socialSharer }
    var cardSocialMessage: Observable<SocialMessage?> { return socialMessage.asObservable() }

    // MARK: ListingCardViewCellModel
    var cardListing: Listing { return listing.value }
    var cardListingObs: Observable<Listing> { return listing.asObservable() }
    var cardStatus: Observable<ListingViewModelStatus>  { return status.asObservable() }
    var cardIsShowingFeaturedStripe: Observable<Bool> { return isShowingFeaturedStripe.asObservable() }
    var cardNavBarButtons: Observable<[UIAction]> { return navBarButtons.asObservable() }
    var cardActionButtons: Observable<[UIAction]> { return actionButtons.asObservable() }
    var cardAltActions: Observable<[UIAction]> { return altActions.asObservable() }

    var cardIsFavoritable: Bool { return !isMine }
    var cardIsFeatured: Observable<Bool> { return isShowingFeaturedStripe.asObservable() }
    var productIsFavorite: Observable<Bool> { return isFavorite.asObservable() }
    var cardUserInfo: Observable<ListingVMUserInfo> { return userInfo.asObservable() }
    var cardProductImageURLs: Observable<[URL]> { return productImageURLs.asObservable() }

    var cardQuickAnswers: [[QuickAnswer]] { return quickAnswers }
    var cardDirectChatEnabled: Observable<Bool> { return directChatEnabled.asObservable() }
    var cardDirectChatMessages: Observable<CollectionChange<ChatViewMessage>> { return directChatMessages.changesObservable }
    var cardDirectChatPlaceholder: String { return directChatPlaceholder }

    var cardBumpUpBannerInfo: Observable<BumpUpInfo?> { return bumpUpBannerInfo.asObservable() }
}
