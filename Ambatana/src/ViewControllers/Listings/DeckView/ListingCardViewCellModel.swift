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
import RxCocoa

protocol ListingCardDetailsViewModel: class {
    var cardProductInfo: Observable<ListingVMProductInfo?> { get }
    var cardProductStats: Observable<ListingStats?> { get }
    var cardSocialSharer: SocialSharer { get }
    var cardSocialMessage: Observable<SocialMessage?> { get }
    var cardShowExactLocationOnMap: Observable<Bool> { get }
}

protocol ListingCardViewCellModel: ListingCardDetailsViewModel {
    var cardListingObs: Observable<Listing> { get }

    var cardStatus: Observable<ListingViewModelStatus> { get }
    var cardActionButtons: Observable<[UIAction]> { get }

    var cardIsFavoritable: Bool { get }
    var cardIsFeatured: Observable<Bool> { get  }

    var productIsFavorite: Observable<Bool> { get }
    var cardUserInfo: Observable<ListingVMUserInfo> { get }
    var cardProductPreview: Observable<(URL?, Int)> { get }
    
    var cardQuickAnswers: [QuickAnswer] { get }
    var cardDirectChatEnabled: Observable<Bool> { get }
    var cardDirectChatMessages: Observable<CollectionChange<ChatViewMessage>> { get }
    var cardDirectChatPlaceholder: String { get }
    var cardBumpUpBannerInfo: Observable<BumpUpInfo?> { get }
    var shouldShowReputationTooltip: Driver<Bool> { get }
    func reputationTooltipShown()
}

extension ListingViewModel: ListingCardViewCellModel {

    // MARK: ListingCardDetailsViewModel
    var cardProductInfo: Observable<ListingVMProductInfo?> { return productInfo.asObservable() }
    var cardProductStats: Observable<ListingStats?> { return listingStats.asObservable() }
    var cardSocialSharer: SocialSharer { return socialSharer }
    var cardSocialMessage: Observable<SocialMessage?> { return socialMessage.asObservable() }

    // MARK: ListingCardViewCellModel
    var cardListingObs: Observable<Listing> { return listing.asObservable() }
    var cardStatus: Observable<ListingViewModelStatus>  { return status.asObservable() }
    var cardActionButtons: Observable<[UIAction]> { return actionButtons.asObservable() }

    var cardIsFavoritable: Bool { return !isMine }
    var cardIsFeatured: Observable<Bool> { return isShowingFeaturedStripe.asObservable() }
    var productIsFavorite: Observable<Bool> { return isFavorite.asObservable() }
    var cardUserInfo: Observable<ListingVMUserInfo> { return userInfo.asObservable() }
    var cardProductPreview: Observable<(URL?, Int)> { return previewURL.asObservable()}

    var cardQuickAnswers: [QuickAnswer] { return quickAnswers }
    var cardDirectChatEnabled: Observable<Bool> { return directChatEnabled.asObservable() }
    var cardDirectChatMessages: Observable<CollectionChange<ChatViewMessage>> { return directChatMessages.changesObservable }
    var cardDirectChatPlaceholder: String { return directChatPlaceholder }

    var cardBumpUpBannerInfo: Observable<BumpUpInfo?> { return bumpUpBannerInfo.asObservable() }

    var cardShowExactLocationOnMap: Observable<Bool> { return showExactLocationOnMap.asObservable() }

    var shouldShowReputationTooltip: Driver<Bool> {
        return userInfo.asDriver().map { [weak self] in
            guard let strongSelf = self else { return false }
            return $0.badge != .noBadge && strongSelf.reputationTooltipManager.shouldShowTooltip()
        }
    }

    func reputationTooltipShown() {
        reputationTooltipManager.didShowTooltip()
    }
}
